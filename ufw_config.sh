#!/usr/bin/env bash

#Shortcuts of colors
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
RESET='\e[0m'

sudo ufw default deny incoming > /dev/null 2>&1
sudo ufw default allow outgoing > /dev/null 2>&1

sudo ufw allow 80/tcp > /dev/null 2>&1
sudo ufw allow 443/tcp > /dev/null 2>&1
sudo ufw allow 443/udp > /dev/null 2>&1
sudo ufw allow 10122/tcp > /dev/null 2>&1

sudo ufw --force enable > /dev/null 2>&1

echo -e "${GREEN}[OK] ${RESET} Firewall was configured and enabled\n"
#sudo ufw status verbose
