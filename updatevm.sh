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
echo -e "\n${GREEN}System was sucsessfully updated${RESET}\n"
