#!/bin/bash

export LC_ALL=C.UTF-8
export LANG=C.UTF-8
export LANGUAGE=C.UTF-8

set -e

# Color definitions
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
MAGENTA='\e[35m'
CYAN='\e[36m'
RESET='\e[0m'
SERVICE_NAME="asa"


# Base directory for all instances
BASE_DIR="/opt/asa"
RCON_SCRIPT="$BASE_DIR/rcon.py"

CONFIG_DIR="$BASE_DIR/customconfig"
ENV_FILE="$CONFIG_DIR/asa.env"
START_SCRIPT="$BASE_DIR/start-asa.sh"
SERVICE_FILE="/etc/systemd/system/asa.service"

# Define the base paths as variables
STEAMCMD_DIR="$BASE_DIR/steamcmd"
SERVER_FILES_DIR="$BASE_DIR/server-files"
PROTON_VERSION="GE-Proton10-4"
PROTON_DIR="$BASE_DIR/$PROTON_VERSION"

# Define URLs for SteamCMD and Proton.
STEAMCMD_URL="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
PROTON_URL="https://github.com/GloriousEggroll/proton-ge-custom/releases/download/$PROTON_VERSION/$PROTON_VERSION.tar.gz"

echo -e "${CYAN}== ARK Survival Ascended installer (single server) ==${RESET}"

# -------------------------------------------------------------------
# Dependencies
# -------------------------------------------------------------------
echo -e "${CYAN}Installing dependencies...${RESET}"
dpkg --add-architecture i386
dependencies=("wget" "tar" "grep" "libc6:i386" "libstdc++6:i386" "libncursesw6:i386" "python3" "libfreetype6:i386" "libfreetype6:amd64" "cron")

apt update
apt install -y "${dependencies[@]}"
echo -e "${GREEN}Installed dependencies...${RESET}"

# -------------------------------------------------------------------
# Directories
# -------------------------------------------------------------------
mkdir -p "$STEAMCMD_DIR" "$SERVER_FILES_DIR" "$PROTON_DIR" "$CONFIG_DIR"

# -------------------------------------------------------------------
# SteamCMD
# -------------------------------------------------------------------
if [ ! -f "$STEAMCMD_DIR/steamcmd.sh" ]; then
    echo -e "${CYAN}Downloading SteamCMD...${RESET}"
    wget -q -O "$STEAMCMD_DIR/steamcmd_linux.tar.gz" "$STEAMCMD_URL"
    tar -xzf "$STEAMCMD_DIR/steamcmd_linux.tar.gz" -C "$STEAMCMD_DIR"
    rm "$STEAMCMD_DIR/steamcmd_linux.tar.gz"
		echo -e "${GREEN}Installed SteamCMD...${RESET}"
else
    echo -e "${GREEN}SteamCMD already installed.${RESET}"
fi

# -------------------------------------------------------------------
# Proton GE
# -------------------------------------------------------------------
if [ ! -d "$PROTON_DIR/files" ]; then
    echo -e "${CYAN}Downloading Proton GE...${RESET}"
    wget -q -O "$PROTON_DIR/$PROTON_VERSION.tar.gz" "$PROTON_URL"
    tar -xzf "$PROTON_DIR/$PROTON_VERSION.tar.gz" -C "$PROTON_DIR" --strip-components=1
    rm "$PROTON_DIR/$PROTON_VERSION.tar.gz"
		echo -e "${GREEN}Installed Proton GE...${RESET}"
else
    echo -e "${GREEN}Proton already installed.${RESET}"
fi



# -------------------------------------------------------------------
# ARK server install / update
# -------------------------------------------------------------------
echo -e "${CYAN}Installing ARK server...${RESET}"
export HOME="$BASE_DIR"
"$STEAMCMD_DIR/steamcmd.sh" \
  +@sSteamCmdForcePlatformType windows \
  +force_install_dir "$SERVER_FILES_DIR" \
  +login anonymous \
  +app_update 2430930 validate \
  +quit
echo -e "${GREEN}Installed ARK server...${RESET}"
# -------------------------------------------------------------------
# Proton prefix (one-time)
# -------------------------------------------------------------------

PROTON_PREFIX="$SERVER_FILES_DIR/steamapps/compatdata/2430930"

if [ ! -d "$PROTON_PREFIX/pfx" ]; then
    echo -e "${CYAN}Initializing Proton prefix...${RESET}"
    mkdir -p "$PROTON_PREFIX"
    cp -r "$PROTON_DIR/files/share/default_pfx/." "$PROTON_PREFIX/"
    echo -e "${GREEN}Initialized Proton prefix...${RESET}"
else
    echo -e "${GREEN}Proton prefix already initialized.${RESET}"
fi

# -----------------------------
# Create default config
# -----------------------------
echo -e "${CYAN}Creating default config file...${RESET}"
if [ ! -f "$ENV_FILE" ]; then
cat <<'EOF' > "$ENV_FILE"
# ARK Survival Ascended configuration

MAP_NAME=TheIsland_WP
SERVER_NAME="ARK ASA Server"
MAX_PLAYERS=20

GAME_PORT=7777
QUERY_PORT=27015
RCON_PORT=27020

# Comma-separated mod IDs
MOD_IDS=""

# Cluster (Optional Set cluster ID when ready to use)
CLUSTER_ID=""
CLUSTER_DIR="/opt/asa/cluster"

# Extra flags
EXTRA_ARGS="-NoBattlEye -crossplay"
EOF
fi
echo -e "${GREEN}Created default config file...${RESET}"
# -----------------------------
# Start script
# -----------------------------
echo -e "${CYAN}Creating start script...${RESET}"

cat <<'EOF' > "$START_SCRIPT"
#!/bin/bash
set -e

source /opt/asa/customconfig/asa.env

BASE_DIR="/opt/asa"
SERVER_FILES_DIR="$BASE_DIR/server-files"
STEAMCMD_DIR="$BASE_DIR/steamcmd"
PROTON_DIR="$BASE_DIR/GE-Proton10-4"

# -----------------------------
# Optional cluster support
# -----------------------------
CLUSTER_ARGS=""
if [ -n "$CLUSTER_ID" ]; then
  mkdir -p "$CLUSTER_DIR"
  CLUSTER_ARGS="-ClusterDirOverride=$CLUSTER_DIR -ClusterId=$CLUSTER_ID"
fi

# -----------------------------
# Auto-update ASA before start
# -----------------------------
if [ -f "$STEAMCMD_DIR/steamcmd.sh" ]; then
  echo "[ASA] Checking for updates via SteamCMD..."
  "$STEAMCMD_DIR/steamcmd.sh" \
    +force_install_dir "$SERVER_FILES_DIR" \
    +login anonymous \
    +app_update 2430930 validate \
    +quit
fi

# -----------------------------
# Proton environment
# -----------------------------
export STEAM_COMPAT_DATA_PATH="$SERVER_FILES_DIR/steamapps/compatdata/2430930"
export STEAM_COMPAT_CLIENT_INSTALL_PATH="$BASE_DIR"

# -----------------------------
# Mods
# -----------------------------
MOD_ARG=""
if [ -n "$MOD_IDS" ]; then
  MOD_ARG="-mods=$MOD_IDS"
fi

# -----------------------------
# Start server (PID belongs to systemd)
# -----------------------------
exec "$PROTON_DIR/proton" run \
  "$SERVER_FILES_DIR/ShooterGame/Binaries/Win64/ArkAscendedServer.exe" \
  "$MAP_NAME?listen?SessionName=$SERVER_NAME?RCONEnabled=True" \
  -WinLiveMaxPlayers=$MAX_PLAYERS \
  -Port=$GAME_PORT \
  -QueryPort=$QUERY_PORT \
  -RCONPort=$RCON_PORT \
  $EXTRA_ARGS \
  $MOD_ARG \
	$CLUSTER_ARGS \
  -server -log -nosteamclient -game
EOF

chmod +x "$START_SCRIPT"
echo -e "${GREEN}Created start script...${RESET}"
# -----------------------------
# systemd service
# -----------------------------
echo -e "${CYAN}Creating service...${RESET}"
cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=ARK Survival Ascended Server
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/asa
ExecStart=/opt/asa/start-asa.sh
Restart=on-failure
RestartSec=10
TimeoutStopSec=120
KillSignal=SIGTERM

[Install]
WantedBy=multi-user.target
EOF
echo -e "${GREEN}Created service...${RESET}"

# Reload systemd and enable service
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable --now "$SERVICE_NAME"

echo -e "${GREEN}Installation complete.${RESET}"
echo
echo -e "${CYAN}Service status:${RESET}"
systemctl status "$SERVICE_NAME" --no-pager



