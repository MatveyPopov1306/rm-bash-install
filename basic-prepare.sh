#!/usr/bin/env bash

#Shortcuts of colors
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
RESET='\e[0m'

#Update and upgrade new system
sudo apt update -y && sudo apt upgrade -y
clear
echo -e "${GREEN}[OK]${RESET} System was sucsessfully updated"

SSHPORT="10122" #Default new value of OpenSSH port

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
sed -i "s|^#\?Port .*$|Port ${SSHPORT}|" "/etc/ssh/sshd_config"

#Reload daemon to activate new SSH port
sudo systemctl daemon-reload && sudo systemctl restart ssh

#Show current listening ports
echo -e "${GREEN}[OK]${RESET} Default OpenSSH port was changed to $SSHPORT"
#echo -e "Listening ports are listed below:"
#ss -ntpl

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

echo -e "${GREEN}[OK]${RESET} SSH-password authentification was disabled"



UFW_RULES_FILE="/etc/ufw/before.rules"

# Change ACCEPT to DROP in icmp code for INPUT
sed -i 's/-A ufw-before-input -p icmp --icmp-type destination-unreachable -j ACCEPT/-A ufw-before-input -p icmp --icmp-type destination-unreachable -j DROP/' "$UFW_RULES_FILE"
sed -i 's/-A ufw-before-input -p icmp --icmp-type time-exceeded -j ACCEPT/-A ufw-before-input -p icmp --icmp-type time-exceeded -j DROP/' "$UFW_RULES_FILE"
sed -i 's/-A ufw-before-input -p icmp --icmp-type parameter-problem -j ACCEPT/-A ufw-before-input -p icmp --icmp-type parameter-problem -j DROP/' "$UFW_RULES_FILE"
sed -i 's/-A ufw-before-input -p icmp --icmp-type echo-request -j ACCEPT/-A ufw-before-input -p icmp --icmp-type echo-request -j DROP/' "$UFW_RULES_FILE"

#Append a new string to rules
sed -i '/-A ufw-before-input -p icmp --icmp-type echo-request -j DROP/a -A ufw-before-input -p icmp --icmp-type source-quench -j DROP' "$UFW_RULES_FILE"

# Change ACCEPT to DROP in icmp code for FORWARD
sed -i 's/-A ufw-before-forward -p icmp --icmp-type destination-unreachable -j ACCEPT/-A ufw-before-forward -p icmp --icmp-type destination-unreachable -j DROP/' "$UFW_RULES_FILE"
sed -i 's/-A ufw-before-forward -p icmp --icmp-type time-exceeded -j ACCEPT/-A ufw-before-forward -p icmp --icmp-type time-exceeded -j DROP/' "$UFW_RULES_FILE"
sed -i 's/-A ufw-before-forward -p icmp --icmp-type parameter-problem -j ACCEPT/-A ufw-before-forward -p icmp --icmp-type parameter-problem -j DROP/' "$UFW_RULES_FILE"
sed -i 's/-A ufw-before-forward -p icmp --icmp-type echo-request -j ACCEPT/-A ufw-before-forward -p icmp --icmp-type echo-request -j DROP/' "$UFW_RULES_FILE"

echo -e "${GREEN}[OK]${RESET} Server ping was disabled"

#Setting up an ufw
sudo ufw default deny incoming > /dev/null 2>&1
sudo ufw default allow outgoing > /dev/null 2>&1

sudo ufw allow 80/tcp > /dev/null 2>&1
sudo ufw allow 443/tcp > /dev/null 2>&1
sudo ufw allow 443/udp > /dev/null 2>&1
sudo ufw allow $SSHPORT/tcp > /dev/null 2>&1

sudo ufw --force enable > /dev/null 2>&1

echo -e "${GREEN}[OK]${RESET} Firewall was configured and enabled\n"






