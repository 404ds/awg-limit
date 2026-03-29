# 🚀 AmneziaWG Peers Speed Limit

![version](https://img.shields.io/badge/version-v1.0-green)
![bash](https://img.shields.io/badge/bash-script-blue)
![platform](https://img.shields.io/badge/platform-linux-lightgrey)
![status](https://img.shields.io/badge/status-stable-brightgreen)

[🇬🇧 EN](README.md) | [🇷🇺 RU](README.md.ru)

---

## ⚡ Что это?

Лёгкий инструмент для **ограничения скорости отдельных WireGuard-пиров** внутри Docker-контейнеров AmneziaWG.

✔ No daemon
✔ Minimal CPU usage
✔ Designed for Amnezia VPN

---

## 🖼 Демонстрация

![demo](awg-limit.png)

---

## ⚡ Быстрая установка (рекомендуется)

```bash
curl -o awg-limit.sh https://raw.githubusercontent.com/404ds/awg-limit/main/awg-limit.sh
chmod +x awg-limit.sh
sudo ./awg-limit.sh
```

Далее в меню:

```
5) Install service
```

---

## 📦 Полная установка (пошагово)

### 1. Установить curl (если не установлен)

```bash
apt update
apt install curl -y
```

---

### 2. Скачать скрипт

```bash
curl -o awg-limit.sh https://raw.githubusercontent.com/404ds/awg-limit/main/awg-limit.sh
```

---

### 3. Сделать исполняемым

```bash
chmod +x awg-limit.sh
```

---

### 4. Запустить

```bash
sudo ./awg-limit.sh
```

---

### 5. Установить как сервис

В меню:

```
5) Install service
```

👉 Это нужно, чтобы лимиты применялись после перезагрузки

---

## 🖥 Использование

```bash
awg-limit
```

Меню:

```
1) Limit peer
2) Limit ALL
3) Clear ALL
4) Show peers
5) Install service
6) Uninstall service
```

---

## 🧠 Как это работает

* Используется Linux `tc (HTB)`
* Ограничение скорости для каждого IP
* Без полного пересоздания правил
* Работает внутри Docker-контейнеров

---

## 📊 Возможности

* Ограничение скорости одного пира
* Ограничение всех пиров
* Удаление лимита через `0`
* Автоприменение после перезагрузки (systemd)
* Поддержка нескольких контейнеров:

  * `amnezia-awg`
  * `amnezia-awg2`

---

## 🧩 Совместимость

Поддерживаются:

* [Amnezia Legacy](https://docs.amnezia.org/ru/documentation/instructions/install-vpn-on-server)
* [Amnezia 2.0](https://docs.amnezia.org/ru/documentation/instructions/new-amneziawg-selfhosted)

Официальный клиент:

* [Amnezia VPN client](https://github.com/amnezia-vpn/amnezia-client)

---

## 🔒 Требования

* Linux (Ubuntu/Debian)
* Docker
* Установленный через официальный клиент AmneziaWG
* root / sudo доступ

---

## 🚧 Планы развития

Планируется:

* 🤖 Telegram-бот (в следующей версии)
* 📊 Мониторинг в реальном времени
* 📈 Статистика трафика
* ⚙️ Расширенные функции

---

## ⭐ Поддержка

Если проект полезен — поставь ⭐ на GitHub

---

## 📌 Версия

v1.0
