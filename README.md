# STILL IN DEVELOPPEMENT

# WORKING but steamcmd sometimes dosent work need to run command twice

# Run install using this : 

	bash -c "$(curl -fsSL https://raw.githubusercontent.com/DragoQC/ASA_SingleServer_Proxmox_Script/main/asa-install-single-server.sh)"


🦖 ARK Survival Ascended – Linux Server Installer (Systemd + Proton)

	One server. One LXC.
	Install, update, and run ARK Survival Ascended on Linux using SteamCMD + Proton GE, fully managed by systemd.
	This script is designed for self-hosters, homelabbers, and cluster admins who want a clean, reliable, and scalable setup.

✨ Features

	🦕 Single-server design
	One ARK server per machine / LXC
	Clean isolation, easy resource limits

⚙️ Systemd managed

	systemctl start | stop | restart asa
	Automatic restarts on crash
	Logs via journalctl

🔄 Auto-update on restart

	Server updates itself every time you restart the service
	No manual SteamCMD runs needed

🧬 Optional cluster support

	Enable cluster later without reinstalling
	Works across multiple machines
	Shared cluster folder via mount / bind

🧩 Mod support

	Mods passed via command-line (-mods=)
	Change mods → restart service → done

📦 Clean file layout

	Everything lives in /opt/asa
	One simple config file for users

📁 Directory Layout

/opt/asa/
├── start-asa.sh              # Server start wrapper (used by systemd)
├── customconfig/
│   └── asa.env               # MAIN CONFIG FILE (edit this)
├── server-files/             # ARK server files (SteamCMD)
├── steamcmd/                 # SteamCMD
├── GE-Proton10-4/             # Proton GE
└── cluster/                  # (Optional) Cluster shared folder

🚀 Installation

	1️⃣ Clone or copy the installer script
		git clone https://github.com/yourname/asa-linux-installer.git
		cd asa-linux-installer

	2️⃣ Run the installer
		sudo ./install-asa.sh

	That’s it.
	The server will install, configure, enable systemd, and start automatically.

⚙️ Configuration (Important)

	All user-editable settings are in:
	/opt/asa/customconfig/asa.env

Example config:

	MAP_NAME=TheIsland_WP
	SERVER_NAME=ARK ASA Server
	MAX_PLAYERS=20
	GAME_PORT=7777
	QUERY_PORT=27015
	RCON_PORT=27020
	MOD_IDS=123456789,987654321
	#Cluster (optional)
	CLUSTER_ID=
	CLUSTER_DIR=/opt/asa/cluster
	EXTRA_ARGS="-NoBattlEye -crossplay"


👉 After editing, apply changes with:

	systemctl restart asa

🧬 Cluster Support (Optional)

	Cluster is disabled by default.
	To enable clustering:
	Mount the same shared folder into every server machine:
	/opt/asa/cluster

Edit asa.env:

	CLUSTER_ID=mycluster
	CLUSTER_DIR=/opt/asa/cluster

Restart the server:

	systemctl restart asa


🦖 Result:

	Players can upload/download characters, dinos, and items between maps.
	🔄 Updating the Server
	No special command needed.

Every time you run systemctl restart asa
The server will:

	Stop
	Check for updates via SteamCMD
	Validate files
	Start again

🧾 Logs & Status

	Check server status
	systemctl status asa
	Follow live logs
	journalctl -u asa -f

🛑 Stop / Start / Restart

	systemctl stop asa
	systemctl start asa
	systemctl restart asa

🧠 Design Philosophy

	✔ Simple over clever
	✔ One server = one process
	✔ No tmux / screen / pkill hacks
	✔ systemd owns the PID
	✔ Easy to migrate, backup, and scale

This is not a panel.
This is infrastructure.

⚠️ Notes & Warnings

	Restarting the service may take 1–2 minutes (SteamCMD update check)
	Do not run multiple servers using the same install directory
	For clusters, never run two servers on the same map

🦖 Why this exists

	ARK ASA is Windows-only
	Proton works
	Panels overcomplicate things
	Linux deserves better tooling

❤️ Credits

	Valve – SteamCMD
	GloriousEggroll – Proton GE
	Wildcard – ARK Survival Ascended
	You – for hosting your own damn servers 🦕