systemctl stop asa
/opt/asa/steamcmd/steamcmd.sh \
  +@sSteamCmdForcePlatformType windows \
  +force_install_dir /opt/asa/server-files \
  +login anonymous \
  +app_update 2430930 validate \
  +quit
systemctl start asa
