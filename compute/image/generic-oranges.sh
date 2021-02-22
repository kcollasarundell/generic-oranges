#!/bin/bash
set -eux -o pipefail

INSTALL_PATH=/opt/generic-oranges
SERVICE_NAME=generic-oranges

adduser --system \
  --home $INSTALL_PATH \
  $SERVICE_NAME
 
mkdir -p $INSTALL_PATH
mv /tmp/$SERVICE_NAME $INSTALL_PATH/.
chown -R $SERVICE_NAME $INSTALL_PATH 
chmod +x $INSTALL_PATH/$SERVICE_NAME

cat <<EOF > /etc/systemd/system/$SERVICE_NAME.service
 [Unit]
Description=Generic-oranges
After=network.target
 
[Service]
Type=simple
User=generic-oranges

Restart=on-failure
RestartSec=1
StartLimitInterval=2
StartLimitBurst=50

WorkingDirectory=$INSTALL_PATH
ExecStart=$INSTALL_PATH/$SERVICE_NAME
EOF

sudo systemctl daemon-reload
sudo systemctl enable ${SERVICE_NAME}
sudo systemctl start ${SERVICE_NAME}
sudo systemctl status ${SERVICE_NAME}
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent
sudo systemctl status amazon-ssm-agent