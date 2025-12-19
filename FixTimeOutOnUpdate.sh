systemctl edit asa.service


Add this override:
[Service]
TimeoutStartSec=0