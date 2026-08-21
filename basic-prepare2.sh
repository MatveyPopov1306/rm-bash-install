#!/usr/bin/env bash

#Shortcuts of colors
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
RESET='\e[0m'

OK="${GREEN}[OK]${RESET}"
ERROR="${RED}[ERROR]${RESET}"
WARNING="${YELLOW}[WARNING]${RESET}"

USERNAME="admin"
PASSWORD="password"
SSHPORT="10122"
SKIPUPDATE=false

# Parsing cycle
while [[ $# -gt 0 ]]; do
    case "$1" in
        --username)
            USERNAME="$2"
            shift 2
            ;;
        --userpassword)
            PASSWORD="$2"
            shift 2
            ;;
        --sshport)
            SSHPORT="$2"
            shift 2
            ;;
        --skip-update)
            SKIPUPDATE=true
            shift
            ;;
        *)
            echo "An unknown parameter was passed: $1"
            echo "$ERROR installation was cancelled"
            exit 1
            ;;
    esac
done

update_system(){
	if [ "$SKIPUPDATE" = true ]; then
		clear
		echo -e "$WARNING Skipped update becatuse of parameter --skip-update: $SKIPUPDATE"
	else
		sudo apt update
		sudo apt upgrade -y
		clear
		echo -e "$OK System was sucsessfully updated"		
	fi
}

create_user() {
	if id "$USERNAME" &>/dev/null; then
		echo -e "$WARNING User $USERNAME already exists, skipping."
	else
    	sudo useradd -m -s /bin/bash "$USERNAME"
   		echo "$USERNAME:$PASSWORD" | sudo chpasswd
    	sudo usermod -aG sudo "$USERNAME"
		echo -e "$OK User $USERNAME was successfully created."
	fi
}

main(){
	update_system
	create_user
}

main




