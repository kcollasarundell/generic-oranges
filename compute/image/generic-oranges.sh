#!/bin/bash
set -eux -o pipefail

INSTALL_PATH=/opt/generic-oranges
SERVICE_NAME=generic-oranges



useradd -d $INSTALL_PATH \
 --shell /usr/sbin/nologin \
 --user-group \
 $SERVICE_NAME
 
mkdir -p $INSTALL_PATH
mv /tmp/$SERVICE_NAME $INSTALL_PATH/.
chown -r $INSTALL_PATH $SERVICE_NAME:$SERVICE_NAME
chmod +x $INSTALL_PATH/$SERVICE_NAME



cat <<EOF > /etc/systemd/system/$SERVICE_NAME.service
 [Unit]
Description=Generic-oranges
After=network.target
 
[Service]
Type=simple
User=generic-oranges
Group=generic-oranges

Restart=on-failure
RestartSec=1
startLimitIntervalSec=60

WorkingDirectory=$INSTALL_PATH
ExecStart=$INSTALL_PATH/$SERVICE_NAME
EOF

systemctl daemon-reload
systemctl enable generic-oranges