# 🦖 ARK: Survival Ascended – Single Server Installer (Proxmox / LXC)

This repository provides a **Bash script** to install and run **ARK: Survival Ascended** on Linux using **SteamCMD + Proton GE**, fully managed by **systemd**.

The main objective is to run **one ARK ASA server per LXC container** in order to achieve:

- 🧱 Clean isolation
- 📉 Easy CPU / RAM / disk limits
- 💾 Predictable disk usage (less than 10 GB per server)
- 📦 Simple scaling on Proxmox

This project is designed for **self-hosters**, **homelab setups**, and **Proxmox users**.

---

## ✅ Requirements

- 🐧 **Debian 13**
- 🌐 **curl** installed
- 📦 **Debian 13 LXC container** (tested)

⚠️ Each LXC container must host **only one ARK server**.

---

## 🚀 Installation

Run the installer directly:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/DragoQC/ASA_SingleServer_Proxmox_Script/main/asa-install-single-server.sh)"
```

> ℹ️ **Note**  
> SteamCMD may occasionally fail on the first run.  
> If that happens, simply run the command again.

---

## ✨ Features

- One server per LXC
- systemd managed service
- Automatic restart on crash
- Automatic update on service restart
- Optional cluster support
- Mod support via command-line
- Clean and simple file layout
- Example `Game.ini` and `GameUserSettings.ini` included

---

## 📁 Directory Layout

```text
/opt/asa/
├── start-asa.sh
├── server-config/
│   └── asa.env
├── server-files/
├── steamcmd/
├── GE-Proton10-4/
└── cluster/
```

## ⚙️ Configuration

All user configuration is done in:

```bash
/opt/asa/server-config/asa.env
```

### Example

```env
MAP_NAME=TheIsland_WP
SERVER_NAME="ARK ASA Server"
MAX_PLAYERS=20

GAME_PORT=7777
QUERY_PORT=27015
RCON_PORT=27020

MOD_IDS="123456789,987654321"

CLUSTER_ID=""
CLUSTER_DIR="/opt/asa/cluster"

EXTRA_ARGS="-NoBattlEye -crossplay"
```
---

### Apply changes

Run the following command:
```bash
systemctl restart asa
```

🧬 Cluster Support (Optional)

Cluster support is disabled by default.

To enable it

Mount the same shared directory on each server:
```bash
/opt/asa/cluster
```
Edit asa.env and set:
```bash
CLUSTER_ID=mycluster

CLUSTER_DIR=/opt/asa/cluster
```
Restart the service:
```bash
systemctl restart asa
```
Players will be able to transfer characters, dinos, and items between maps.

🔄 Updating the Server

No manual update command is required.

Every time you run:
```bash
systemctl restart asa
```
The server will:
```text
Stop
Check for updates via SteamCMD
Validate files
Start again
```
🛠️ Service Commands

- Start the server:
```bash
systemctl start asa
```
- Stop the server:
```bash
systemctl stop asa
```
- Restart the server:
```bash
systemctl restart asa
```

📜 Logs
```text
Check service status:
systemctl status asa
Follow live logs:
journalctl -u asa -f
```

⚠️ Notes
>Restarting the service can take 1–2 minutes due to SteamCMD checks
>Do not run multiple servers from the same install directory

❓ Why This Exists
- ARK ASA is Windows-only
- Proton works well
- Game panels overcomplicate simple infrastructure
- Linux deserves clean, scriptable tooling

❤️ Credits
- Valve – SteamCMD
- GloriousEggroll – Proton GE
- Wildcard – ARK: Survival Ascended
- You – for hosting your own servers

