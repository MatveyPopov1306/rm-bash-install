#!/usr/bin/env bash

#Shortcuts of colors
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
RESET='\e[0m'

PORT="10122" #Default new value of OpenSSH port

#Parsing cycle
while [[ $# -gt 0 ]]; do
    case "$1" in
        --port)
            PORT="$2"
            shift 2
            ;;
        *)
            echo -e "An unknown parameter was passed: $1"
            echo -e "${RED}[ERROR]${RESET} installation was cancelled"
            exit 1
            ;;
    esac
done

#Change default OpenSSH port to custom 10122 port-ssh
FILE="/etc/ssh/sshd_config"
sed -i "s|^#\?Port .*$|Port ${PORT}|" "$FILE"

#Reload daemon to activate new SSH port
sudo systemctl daemon-reload && sudo systemctl restart ssh

#Show current listening ports
echo -e "Default OpenSSH port: 22 was changed to $PORT"
echo -e "Listening ports are listed below:"
ss -ntpl
