sudo tee /etc/systemd/system/wifi-resume.service <<EOF
[Unit]
Description=Reset WiFi after suspend
After=suspend.target

[Service]
Type=simple
ExecStart=/usr/bin/nmcli radio wifi off && sleep 1 && /usr/bin/nmcli radio wifi on

[Install]
WantedBy=suspend.target
EOF

sudo systemctl enable wifi-resume.service
