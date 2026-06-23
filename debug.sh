#!/usr/bin/env bash

#Basic update of system
bash <(curl -Ls https://raw.githubusercontent.com/MatveyPopov1306/rm-bash-install/main/updatevm.sh)
#Change default ssh port to custom
bash <(curl -Ls https://raw.githubusercontent.com/MatveyPopov1306/rm-bash-install/main/change_default-ssh.sh)
#Disable password authentification, allow only using ssh-key
bash <(curl -Ls https://raw.githubusercontent.com/MatveyPopov1306/rm-bash-install/main/disable_passwordauth.sh)
#Disable server ping
bash <(curl -Ls https://raw.githubusercontent.com/MatveyPopov1306/rm-bash-install/main/disable_ping_server.sh)
