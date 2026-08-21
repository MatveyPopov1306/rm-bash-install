#!/usr/bin/env bash

#Shortcuts of colors
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
RESET='\e[0m'

OK="${GREEN}[OK]${RESET}"
ERROR="${RED}[ERROR]${RESET}"

USERNAME="admin"
PASSWORD='Qm@11PsL'

update_system(){
	sudo apt update
	sudo apt upgrade -y
}

create_user() {
    sudo useradd -m -s /bin/bash "$USERNAME" 2>/dev/null || true
	echo "$USERNAME:$PASSWORD" | sudo chpasswd
	sudo usermod -aG sudo "$USERNAME"
	sudo -iu "$USERNAME"
}

main(){
	update_system
	create_user
}

main




