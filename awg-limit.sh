#!/bin/bash

CONF="/etc/awg-bandwidth.conf"

CONTAINERS=("amnezia-awg" "amnezia-awg2")

# цвета
#CLR_BLUE=$(tput setaf 4)
CLR_CYAN=$(tput setaf 6)
CLR_PURPLE=$(tput setaf 5)
CLR_RESET=$(tput sgr0)

declare -A PEER_MAP
declare -A PEER_CONTAINER

#--------------------------------------------
detect_interface() {
    local c=$1
    docker exec "$c" ip -o link show | awk -F': ' '{print $2}' | grep -E '^(wg0|awg0)' | head -n1
}

#--------------------------------------------
get_peers() {
    PEERS=()

    for c in "${CONTAINERS[@]}"; do
        docker ps --format '{{.Names}}' | grep -q "^$c$" || continue

        IFACE=$(detect_interface "$c")
        [ -z "$IFACE" ] && continue

        while read ip; do
            [ -z "$ip" ] && continue

# исключаем служебный IP админа
            if [ "$ip" = "10.8.1.1" ]; then
                continue
            fi

            key="$c|$IFACE|$ip"
            PEERS+=("$key")
        done < <(
            docker exec "$c" wg show 2>/dev/null | awk '
            /allowed ips:/ {
                split($3, ip, "/")
                print ip[1]
            }'
        )
    done
}

#--------------------------------------------
get_limit() {
    local key="$1"

    [ -f "$CONF" ] || { echo "-"; return; }

    rate=$(grep "^$key " "$CONF" | awk '{print $2}')
    [ -z "$rate" ] && echo "-" || echo "$rate"
}

#--------------------------------------------
show_peers() {
    get_peers
    i=1
    INDEX_MAP=()

    printf "%-3s %-15s %-6s %-13s %-10s\n" "#" "CONTAINER" "IFACE" "IP" "LIMIT"
    echo "-------------------------------------------------------------"

    for key in $(printf "%s\n" "${PEERS[@]}" | sort -t'|' -k1,1 -k2,2 -k3,3V); do
        c=${key%%|*}
        rest=${key#*|}
        iface=${rest%%|*}
        ip=${rest##*|}

        limit=$(get_limit "$key")

printf "%-3s " "$i)"

case "$c" in
    amnezia-awg)
        printf "%b%-15s%b " "$CLR_PURPLE" "$c" "$CLR_RESET"
        printf "%-6s " "$iface"
        printf "%b%-13s%b " "$CLR_PURPLE" "$ip" "$CLR_RESET"
        ;;
    amnezia-awg2)
        printf "%b%-15s%b " "$CLR_CYAN" "$c" "$CLR_RESET"
        printf "%-6s " "$iface"
        printf "%b%-13s%b " "$CLR_CYAN" "$ip" "$CLR_RESET"
        ;;
    *)
        printf "%-15s %-6s %-13s " "$c" "$iface" "$ip"
        ;;
esac

printf "%-10s\n" "$limit"

        INDEX_MAP[$i]="$key"
        ((i++))
    done
}

#--------------------------------------------
init_tc() {
    local c=$1
    local iface=$2

    # проверяем есть ли уже qdisc
    docker exec "$c" tc qdisc show dev "$iface" 2>/dev/null | grep -q "htb 1:" && return

    # создаём только если нет
    docker exec "$c" tc qdisc add dev "$iface" root handle 1: htb default 999 r2q 100 2>/dev/null
    docker exec "$c" tc class add dev "$iface" parent 1: classid 1:1 htb rate 1000mbit 2>/dev/null
}
#--------------------------------------------
apply_tc() {
    sort -u "$CONF" -o "$CONF"

    while read key rate; do
        [ -z "$key" ] && continue

        c=${key%%|*}
        rest=${key#*|}
        iface=${rest%%|*}
        ip=${rest##*|}

        # убедиться что контейнер жив
        docker ps --format '{{.Names}}' | grep -q "^$c$" || continue

        # init если надо
        init_tc "$c" "$iface"

        # HASH classid
        classid=$(echo -n "$key" | md5sum | cut -c1-6)
        classid=$((0x$classid))
        classid=$((classid % 60000 + 10))
        classid="1:$classid"

        # обновляем класс (важно: replace)
        docker exec "$c" tc class replace dev "$iface" parent 1:1 classid $classid htb rate $rate ceil $rate 2>/dev/null

        # удаляем старые фильтры для этого IP
        docker exec "$c" tc filter del dev "$iface" parent 1:0 protocol ip prio 1 2>/dev/null

        # добавляем заново
        docker exec "$c" tc filter add dev "$iface" protocol ip parent 1:0 prio 1 u32 \
            match ip dst $ip flowid $classid 2>/dev/null

    done < "$CONF"
}

#--------------------------------------------
set_limit() {
    touch "$CONF"

    show_peers
    echo -n "Select peer: "
    read idx

    key=${INDEX_MAP[$idx]}
    [ -z "$key" ] && echo "Invalid" && exit 1

    echo -n "Set speed (1-1000) Mbit/s, 0 - clear limit, numbers only: "
    read rate_input

# проверка число
    if ! [[ "$rate_input" =~ ^[0-9]+$ ]]; then
        echo "Invalid input (numbers only)"
        return
    fi

# диапазон
    if [ "$rate_input" -lt 0 ] || [ "$rate_input" -gt 1000 ]; then
        echo "Allowed range: 0-1000"
        return
    fi

    tmp=$(mktemp)

    # копируем всё кроме текущего ключа
    grep -v "^$key " "$CONF" > "$tmp" 2>/dev/null

    # добавляем новую запись
    if [ "$rate_input" -eq 0 ]; then
        echo "✔ Limit removed"
    else
        rate="${rate_input}mbit"
        echo "$key $rate" >> "$tmp"
    fi

    mv "$tmp" "$CONF"
    c=${key%%|*}
    rest=${key#*|}
    iface=${rest%%|*}
    ip=${rest##*|}

    echo "✔ $c | $iface | $ip → ${rate_input} Mbit/s"
    apply_tc &
}

# ----------------------------------
set_all() {
    touch "$CONF"
    get_peers

    echo -n "Set speed (1-1000) Mbit/s, numbers only: "
    read rate_input

    if ! [[ "$rate_input" =~ ^[0-9]+$ ]]; then
        echo "Invalid input (numbers only)"
        return
    fi

    if [ "$rate_input" -lt 1 ] || [ "$rate_input" -gt 1000 ]; then
        echo "Allowed range: 1-1000"
        return
    fi

    rate="${rate_input}mbit"
    > "$CONF"

    for key in "${PEERS[@]}"; do
        echo "$key $rate" >> "$CONF"
    done
    c=${key%%|*}
    rest=${key#*|}
    iface=${rest%%|*}
    ip=${rest##*|}

    echo "✔ ALL peers set → ${rate_input} Mbit/s"

    apply_tc &
}

# -----------------------------------
clear_all() {
    > "$CONF"

    for c in "${CONTAINERS[@]}"; do
        docker exec "$c" tc qdisc del dev wg0 root 2>/dev/null
        docker exec "$c" tc qdisc del dev awg0 root 2>/dev/null
    done

    echo "✔ Cleared"
}

# -----------------------------------
install_service() {
    cp "$(realpath "$0")" /usr/local/bin/awg-limit
    chmod +x /usr/local/bin/awg-limit

cat > /etc/systemd/system/awg-limit.service <<EOF
[Unit]
Description=AmneziaWG bandwidth limiter
After=docker.service network-online.target
Wants=network-online.target

ConditionPathExists=/usr/bin/docker

[Service]
Type=oneshot

ExecStartPre=/bin/sh -c "for i in \$(seq 1 10); do docker ps --format '{{.Names}}' | grep -qE '^amnezia-awg' && exit 0; sleep 1; done; exit 0"

ExecStart=/usr/local/bin/awg-limit apply

RemainAfterExit=true

[Install]
WantedBy=multi-user.target

EOF

    systemctl daemon-reload
    systemctl enable awg-limit
    echo "✔ Done"
}

# -----------------------------------
uninstall_service() {
    systemctl disable awg-limit 2>/dev/null
    rm -f /etc/systemd/system/awg-limit.service
    rm -f /usr/local/bin/awg-limit
    rm -f /etc/awg-bandwidth.conf
    systemctl daemon-reload
    echo "✔ Done"
}

#---------------------------------------
apply_saved() {
    get_peers
    [ -f "$CONF" ] && apply_tc
}

#-----------------------------------
menu() {
    echo "1) Limit peer"
    echo "2) Limit ALL"
    echo "3) Clear ALL"
    echo "4) Show peers"
    echo "5) Install service"
    echo "6) Uninstall service"
    echo "0) Exit"
    read choice

    case $choice in
        1) set_limit ;;
        2) set_all ;;
        3) clear_all ;;
        4) show_peers ;;
        5) install_service ;;
        6) uninstall_service ;;
        0) exit ;;
    esac
}

case "$1" in
    apply) apply_saved ;;
    *) menu ;;
esac
