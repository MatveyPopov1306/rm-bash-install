#!/usr/bin/env bash

#Update and upgrade new system
#sudo apt update -y && sudo apt upgrade -y
echo "Hello, world"
echo "$1"  # --port
echo "$2"  # 10122
#Change default OpenSSH port to custom 10122 port-ssh
#FILE="/etc/ssh/sshd_config"
#sed -i 's/^#\?Port .*$/Port 10122/' "$FILE"
