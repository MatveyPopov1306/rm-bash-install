#!/usr/bin/env bash

#Update and upgrade new system
#sudo apt update -y && sudo apt upgrade -y
echo "Hello, world"

#Default value of OpenSSH port
PORT="22" 

while [[ $# -gt 0 ]]; do
    case "$1" in
        --port)
            PORT="$2"
            shift 2
            ;;
        *)
            echo "Неизвестный параметр: $1"
            exit 1
            ;;
    esac
done

echo "$PORT"

#Change default OpenSSH port to custom 10122 port-ssh
#FILE="/etc/ssh/sshd_config"
#sed -i 's/^#\?Port .*$/Port 10122/' "$FILE"
