#!/usr/bin/env bash

#Shortcuts of colors
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
RESET='\e[0m'

FILE="/etc/ufw/before.rules"

# Меняем ACCEPT на DROP в нужных строках
sed -i 's/-A ufw-before-input -p icmp --icmp-type destination-unreachable -j ACCEPT/-A ufw-before-input -p icmp --icmp-type destination-unreachable -j DROP/' "$FILE"


#sed '/# ok icmp codes for INPUT/,/# ok icmp code for FORWARD/ s/ACCEPT/DROP/g' "$FILE"
#sed '/# ok icmp code for FORWARD/,/^#/ s/ACCEPT/DROP/g' "$FILE"

# Добавляем source-quench после комментария
#sed '/# ok icmp codes for INPUT/a -A ufw-before-input -p icmp --icmp-type source-quench -j DROP' "$FILE"
