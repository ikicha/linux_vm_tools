#!/bin/bash

cat > /etc/systemd/system/ttyd.service <<EOF
[Unit]
Description=TTYD
After=syslog.target
After=network.target
[Service]
ExecStart=/usr/local/bin/ttyd -W login
Type=simple
Restart=always
User=root
Group=root
[Install]
WantedBy=multi-user.target
EOF
chmod 0644 /etc/systemd/system/ttyd.service

cat > /etc/systemd/system/vsockip.service <<EOF
[Unit]
Description=vsock ip service
[Unit]
Description=vsock ip service
After=multi-user.target
[Service]
Type=simple
Restart=always
ExecStart=/usr/bin/python3 /usr/local/bin/vsock.py
[Install]
WantedBy=multi-user.target
EOF
chmod 0644 /etc/systemd/system/vsockip.service

apt install -y curl wget
wget https://github.com/ikicha/linux_vm_tools/raw/main/vsock.py -O /tmp/vsock.py
install /tmp/vsock.py /usr/local/bin
wget https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.aarch64 -O /tmp/ttyd
install /tmp/ttyd /usr/local/bin
systemctl daemon-reload
systemctl start ttyd && sudo systemctl enable ttyd
systemctl start vsockip && sudo systemctl enable vsockip
