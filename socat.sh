#!/bin/bash
 
#install Shadowsocks on CentOS 7
 
echo "Installing Shadowsocks................................................."
 
CONFIG_FILE=/etc/shadowsocks.json
SS_SERVICE_FILE=/etc/systemd/system/shadowsocks.service
SS_PASSWORD=qweasd_helloworld
SS_PORT=8388
SS_IP=`ip route get 1|awk '{print $NF;exit}'`
 
 
echo "root can install soft"
yum install -y python-setuptools && easy_install pip
 
pip install shadowsocks
 
# creat shadowsocks config
 
cat << EOF | tee ${CONFIG_FILE}
{
    "server":"${SS_IP}",
    "server_port":${SS_PORT},
    "local_address": "127.0.0.1",
    "local_port":1080,
    "password":"${SS_PASSWORD}",
    "timeout":600,
    "method":"aes-256-cfb",
    "fast_open": false
}
EOF
 
# check shadowsock.config && stop shadowsocks.service
ssserver -c /etc/shadowsocks.json -d start
 
echo "Add firewall port....."
 
firewall-cmd --zone=public --add-port=8388/tcp --permanent
 
echo "restart firewall.service..........................................................."
 
systemctl restart firewalld.service
 
 
 
# set shadowssocks.service start with system
 
echo "create ${SS_SERVICE_FILE} && set shadowsocks.service start with system............."
 
cat << EOF | tee ${SS_SERVICE_FILE}
[Unit]
Description=Shadowsocks service
After=network.target
[Service]
Type=simple
User=root
ExecStart=/usr/bin/ssserver -c ${CONFIG_FILE}
ExecReload=/bin/kill -HUP $MAINPID
ExecStop=/bin/kill -s QUIT $MAINPID 
PrivateTmp=true
KillMode=process
Restart=on-failure
RestartSec=5s
[Install]
WantedBy=multi-user.target
EOF
 
echo "Strat shadowsock.service ........................................................"
systemctl daemon-reload
systemctl start shadowsocks.service
systemctl enable shadowsocks.service
 
echo "ALL Done........................................................................."
 
