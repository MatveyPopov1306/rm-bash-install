#!/usr/bin/env bash

#Shortcuts of colors
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
RESET='\e[0m'

OK="${GREEN}[OK]${RESET}"
ERROR="${RED}[ERROR]${RESET}"

PANEL_DOMAIN="" #Addres of your panel domain
SUB_PANEL_DOMAIN="" #Addres of your subscription domain

#Parsing cycle of two variables
while [[ $# -gt 0 ]]; do
    case "$1" in
        --domain)
            PANEL_DOMAIN="$2"
            shift 2
            ;;
        --subdomain)
            SUB_PANEL_DOMAIN="$2"
            shift 2
            ;;
        *)
            echo -e "An unknown parameter was passed: $1. Please check the spelling of the command"
            echo -e "$ERROR installation was cancelled"
            exit 1
            ;;
    esac
done

#Check if user gave us values, else abort
if [[ -z "$PANEL_DOMAIN" || -z "$SUB_PANEL_DOMAIN" ]]; then
    echo -e "$ERROR --domain and --subdomain are required"
    exit 1
fi

#Install Docker if not installed yet
if command -v docker >/dev/null 2>&1; then
    echo -e "$OK Docker is already installed"
else
    curl -fsSL https://get.docker.com | sh
    clear
    echo -e "$OK Sucsessfully installed docker"
fi

#Create project directory
mkdir /opt/remnawave > /dev/null 2>&1 && cd /opt/remnawave

#Download docker-compose.yml and .env.sample by running these commands:
curl -o docker-compose.yml https://raw.githubusercontent.com/remnawave/backend/refs/heads/main/docker-compose-prod.yml > /dev/null 2>&1
curl -o .env https://raw.githubusercontent.com/remnawave/backend/refs/heads/main/.env.sample > /dev/null 2>&1

#Configure the .env file
#Generate secret key by running the following commands:
sed -i "s/^JWT_AUTH_SECRET=.*/JWT_AUTH_SECRET=$(openssl rand -hex 64)/" .env && sed -i "s/^JWT_API_TOKENS_SECRET=.*/JWT_API_TOKENS_SECRET=$(openssl rand -hex 64)/" .env
sed -i "s/^METRICS_PASS=.*/METRICS_PASS=$(openssl rand -hex 64)/" .env && sed -i "s/^WEBHOOK_SECRET_HEADER=.*/WEBHOOK_SECRET_HEADER=$(openssl rand -hex 64)/" .env

#Change the default Postgres password
pw=$(openssl rand -hex 24) && sed -i "s/^POSTGRES_PASSWORD=.*/POSTGRES_PASSWORD=$pw/" .env && sed -i "s|^\(DATABASE_URL=\"postgresql://postgres:\)[^\@]*\(@.*\)|\1$pw\2|" .env

#Add user's domain parametrs into a .env file
ENV_FILE="/opt/remnawave/.env"
sed -i "s|^FRONT_END_DOMAIN=.*$|FRONT_END_DOMAIN=$PANEL_DOMAIN|" "$ENV_FILE"
sed -i "s|^SUB_PUBLIC_DOMAIN=.*$|SUB_PUBLIC_DOMAIN=$SUB_PANEL_DOMAIN|" "$ENV_FILE"

echo -e "$OK Domain addreses were added to .env file"

#Start the containers
docker compose up -d && docker compose logs -f -t







