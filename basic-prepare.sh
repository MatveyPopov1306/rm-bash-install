#!/usr/bin/env bash

#Update and upgrade new system
#sudo apt update -y && sudo apt upgrade -y

while [[ $# -gt 0 ]]; do
    case "$1" in
        --port)
            PORT="$2"
            shift 2
            ;;
    esac
done

echo "$1"
echo "$2"
#Change default OpenSSH port to custom 10122 port-ssh
#FILE="/etc/ssh/sshd_config"
#sed -i 's/^#\?Port .*$/Port 10122/' "$FILE"
