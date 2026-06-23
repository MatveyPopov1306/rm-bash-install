#!/usr/bin/env bash

#Shortcuts of colors
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
RESET='\e[0m'

#Check if personal ssh-key avaliable on vm, else exit script
if [[ ! -s /root/.ssh/authorized_keys ]]; then
    echo -e "\e[31mNo SSH key found for root. Aborting.\e[0m"
    exit 1
fi

sed -i "s|^#\?PasswordAuthentication .*$|PasswordAuthentication no|" \
    /etc/ssh/sshd_config

#Check if the file even exist
if [[ -f /etc/ssh/sshd_config.d/50-cloud-init.conf ]]; then
    sed -i "s|^#\?PasswordAuthentication .*$|PasswordAuthentication no|" \
        /etc/ssh/sshd_config.d/50-cloud-init.conf
fi

#restart systemclt daemon to apply changes
if sshd -t; then
    systemctl restart ssh
else
    echo -e "${RED}SSH config contains errors${RESET}"
    exit 1
fi

echo -e "\n${GREEN}[OK]${RESET} SSH-password authentification was disabled"
