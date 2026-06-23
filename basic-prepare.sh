#!/usr/bin/env bash

RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
RESET='\e[0m'

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
            echo -e "An unknown parameter was passed: $1, ${RED}canceling installation${RED}[0m"
            exit 1
            ;;
    esac
done

echo "$PORT"

#Change default OpenSSH port to custom 10122 port-ssh
#FILE="/etc/ssh/sshd_config"
#sed -i 's/^#\?Port .*$/Port 10122/' "$FILE"
