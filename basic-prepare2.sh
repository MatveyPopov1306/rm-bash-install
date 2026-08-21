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
SKIP_SSH_KEY_SETUP=false

sshd_config_path="/etc/ssh/sshd_config"

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
        --skip-ssh-key-setup)
            SKIP_SSH_KEY_SETUP=true
            shift
            ;;
        *)
            echo "An unknown parameter was passed: $1"
            echo "$ERROR installation was cancelled"
            exit 1
            ;;
    esac
done

update_system() {
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

setup_authorized_keys() {

	local user="$USERNAME"
    local ssh_dir="/home/$user/.ssh"
    local auth_keys="$ssh_dir/authorized_keys"

	if [ "$SKIP_SSH_KEY_SETUP" = true ]; then
		echo -e "$WARNING SSH-key setup was skipped."
		return
	fi

    if [[ -f "$auth_keys" ]] && \
       [[ "$(stat -c %a "$auth_keys")" == "600" ]] && \
       [[ "$(stat -c %a "$ssh_dir")" == "700" ]]; then
		sudo nano "$auth_keys"
        echo -e "$OK Authorized_keys already exists for $USERNAME with correct permissions."
	else
		sudo mkdir -p "$ssh_dir"
    	sudo touch "$auth_keys"
    	sudo chmod 700 "$ssh_dir"
    	sudo chmod 600 "$auth_keys"
    	sudo chown -R "$user:$user" "$ssh_dir"
    	sudo nano "$auth_keys"
		echo -e "$OK Authorized_keys was successfully created for $USERNAME with correct permissions."
    fi
}

change_default_ssh_port() {

	local sshd_cfg_backup="sshd_config_backup"
	local ssh_path="/etc/ssh/"
	
	#check is there are any backup version of sshd_config
	if [ -e "$ssh_path$sshd_cfg_backup" ]; then
		echo -e "$OK A backup copy of sshd_config is already exists with name: $ssh_path$sshd_cfg_backup"
	else
		cp -p /etc/ssh/sshd_config /etc/ssh/sshd_config_backup
		echo -e "$OK A backup copy of sshd_config was made with name: $ssh_path$sshd_cfg_backup"
	fi

	#Change default OpenSSH port to custom 10122 port-ssh
	if [ -e "$sshd_config_path" ]; then
		sed -i "s|^#\?Port .*$|Port ${SSHPORT}|" "$sshd_config_path"
		echo -e "$OK Default OpenSSH port was changed to $SSHPORT"
	else
		echo -e "$ERROR There is no file $sshd_config_path."
	fi
}

change_password_authentication() {
	#Disable password authentification
	sed -i "s|^#\?PasswordAuthentication .*$|PasswordAuthentication no|" \
		/etc/ssh/sshd_config

	#Check if the file even exist
	if [[ -f /etc/ssh/sshd_config.d/50-cloud-init.conf ]]; then
		sed -i "s|^#\?PasswordAuthentication .*$|PasswordAuthentication no|" \
			/etc/ssh/sshd_config.d/50-cloud-init.conf
	fi
	
	echo -e "$OK SSH-password authentification was disabled"
}

change_permit_root_login() {
	#Disable root login
	sed -i "s|^#\?PermitRootLogin .*$|PermitRootLogin no|" \
		/etc/ssh/sshd_config
		
	echo -e "$OK Root login was disabled."
}

set_list_allow_users() {
	if grep -qxF "AllowUsers $USERNAME" "$sshd_config_path"; then
		echo "$WARNING AllowUsers $USERNAME already exists as a parameter in $sshd_config_path"
	else
		echo "AllowUsers $USERNAME" >> "$sshd_config_path"
		echo -e "$OK Login was enabled only for $USERNAME"
	fi
}

ssh_reload() {
	#Reload daemon to activate new SSH port
	sudo systemctl daemon-reload && sudo systemctl restart ssh
}

main(){
	update_system
	create_user
	setup_authorized_keys
	change_default_ssh_port
	change_password_authentication
	change_permit_root_login
	set_list_allow_users
	#ssh_reload
}

main
