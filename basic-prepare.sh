#!/usr/bin/env bash

#Shortcuts of colors
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
RESET='\e[0m'

#Update and upgrade new system
#sudo apt update -y && sudo apt upgrade -y

PORT="10122" #Default value of OpenSSH port

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
clear
echo -e "Default OpenSSH port: 22 was changed to $PORT"
echo -e "Listening ports are listed below:"
ss -ntpl

#Disable ssh-password authentification
if [[ ! -s /root/.ssh/authorized_keys ]]; then
    echo -e "\e[31mNo SSH key found for root. Aborting.\e[0m"
    exit 1
fi

FILE="/etc/ssh/sshd_config"
sed -i "s|^#\?PasswordAuthentication .*$|PasswordAuthentication no|" "$FILE"

FILE="/etc/ssh/sshd_config.d/50-cloud-init.conf"
sed -i "s|^#\?PasswordAuthentication .*$|PasswordAuthentication no|" "$FILE"

sudo systemctl daemon-reload && sudo systemctl restart ssh
echo -e "SSH-password authentification was disabled"
#test











