#!/usr/bin/env bash

#Shortcuts of colors
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
RESET='\e[0m'

OK="${GREEN}[OK]${RESET}"
ERROR="${RED}[ERROR]${RESET}"

PANEL_DOMAIN="koms-rw.zoho.to" #Addres of your panel domain
SUB_PANEL_DOMAIN="koms-rwsub.zoho.to" #Addres of your subscription domain
EMAIN_ADDR="test.mail@gmail.com"

#__________________________________________________COPYLINE_______________________________________________________________

#Install dependencies Socat
if command -v socat >/dev/null 2>&1; then
    echo "$OK Cron and socat already installed"
else
    sudo apt-get install -y cron socat
fi

#Install acme.sh with custom email
#curl https://get.acme.sh | sh -s email=$EMAIN_ADDR && source ~/.bashrc

#Create a folder for the certificates
mkdir -p /opt/remnawave/nginx && cd /opt/remnawave/nginx

#Set Let'sencrypt for issue ssl sertificate
#acme.sh --set-default-ca --server letsencrypt

#Issue a certificate
#acme.sh --issue --standalone -d "$PANEL_DOMAIN" --key-file /opt/remnawave/nginx/privkey.key --fullchain-file /opt/remnawave/nginx/fullchain.pem --reloadcmd "docker exec remnawave-nginx nginx -s reload"

#This shows that the certificate is issued. Acme.sh will take care of automatically renewing the certificate every 60 days
#acme.sh --install-cert -d "$PANEL_DOMAIN" --key-file /opt/remnawave/nginx/privkey.key --fullchain-file /opt/remnawave/nginx/fullchain.pem --reloadcmd "docker exec remnawave-nginx nginx -s reload"

#Create a file called nginx.conf in the /opt/remnawave/nginx directory
cd /opt/remnawave/nginx && curl -o nginx.conf https://raw.githubusercontent.com/MatveyPopov1306/rm-bash-install/main/nginx.conf > /dev/null 2>&1



