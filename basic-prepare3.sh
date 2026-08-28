#!/usr/bin/env bash

#Shortcuts of colors
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
RESET='\e[0m'

#Error codes for echo -e
OK="${GREEN}[OK]${RESET}"
ERROR="${RED}[ERROR]${RESET}"
WARNING="${YELLOW}[WARNING]${RESET}"

update_func() {

sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"

sudo apt install ufw -y
sudo apt install fail2ban -y
sudo apt install speedtest-cli -y

sudo curl -fsSL https://get.docker.com | sh
sudo apt-get install cron socat -y

}

main() {

update_func

}

main
