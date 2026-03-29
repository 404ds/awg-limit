# AmneziaWG Peers Speed Limit

![version](https://img.shields.io/badge/version-v1.0-green)
![bash](https://img.shields.io/badge/bash-script-blue)
![platform](https://img.shields.io/badge/platform-linux-lightgrey)

[![RU](https://img.shields.io/badge/lang-RU-green)](#-ru) 
[![EN](https://img.shields.io/badge/lang-EN-green)](#-en)

---

# 🇷🇺 RU

## 📌 Описание

Скрипт для ограничения скорости отдельных WireGuard-пиров внутри контейнеров **AmneziaWG**.

Поддерживает контейнеры, установленные через официальный клиент:

- <a href="https://docs.amnezia.org/ru/documentation/instructions/install-vpn-on-server">Amnezia Legacy</a>  
- <a href="https://docs.amnezia.org/ru/documentation/instructions/new-amneziawg-selfhosted">Amnezia 2.0</a>  

GitHub клиента:  
- <a href="https://github.com/amnezia-vpn/amnezia-client">AmneziaWG client</a>  

---

## 🚀 Возможности

- Ограничение скорости одного пира
- Ограничение всех пиров
- Удаление лимита через `0`
- Полная очистка лимитов
- Поддержка контейнеров:
  - `amnezia-awg`
  - `amnezia-awg2`
- Автоприменение через systemd

---

## 📦 Установка

```bash
apt install curl
```
Если не установлен

```bash
curl -o awg-limit.sh https://raw.githubusercontent.com/404ds/awg-limit/main/awg-limit.sh
chmod +x awg-limit.sh
sudo ./awg-limit.sh
```

---

## 🖥 Использование

```bash
awg-limit
```

---

## 🖼 Скриншот

![demo](awg-limit.png)

---

## 🔒 Требования

- Linux (Ubuntu/Debian)
- Docker контейнер, установленный через официальный клиент AmneziaWG  
- root / sudo доступ

---

## 🚧 Roadmap

Планируется:

- 🤖 Telegram-бот для управления
- 📊 Мониторинг скорости пиров в реальном времени
- 📈 Статистика по трафику за период
- ⚙️ Дополнительные функции управления

---

# 🇬🇧 EN

## 📌 Description

A bash script to limit bandwidth for WireGuard peers inside **AmneziaWG Docker containers**.

Supports containers installed via official client:

- <a href="https://docs.amnezia.org/en/documentation/instructions/install-vpn-on-server">Amnezia Legacy</a>  
- <a href="https://docs.amnezia.org/en/documentation/instructions/new-amneziawg-selfhosted">Amnezia 2.0</a>  

GitHub client:  
- <a href="https://github.com/amnezia-vpn/amnezia-client">AmneziaWG client</a>  

---

## 🚀 Features

- Limit bandwidth per peer
- Limit all peers
- Remove limit using `0`
- Clear all limits
- Supports containers:
  - `amnezia-awg`
  - `amnezia-awg2`
- systemd auto-apply
- Colored output

---

## 📦 Installation

```bash
curl -o awg-limit.sh https://raw.githubusercontent.com/404ds/awg-limit/main/awg-limit.sh
chmod +x awg-limit.sh
sudo ./awg-limit.sh
```

---

## 🖥 Usage

```bash
awg-limit
```

---

## 🖼 Screenshot

![demo](awg-limit.png)

---

## 🔒 Requirements

- Linux (Ubuntu/Debian)
- Docker AmneziaWG installed via official client  
- root / sudo

---

## 🚧 Roadmap

Planned:

- 🤖 Telegram bot control
- 📊 Real-time peer monitoring
- 📈 Traffic statistics
- ⚙️ Additional features

---

## 📌 Version

v1.0
