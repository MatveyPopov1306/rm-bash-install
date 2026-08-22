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

USERNAME="admin"
PASSWORD="password"
SSHPORT="10122"

# installation flags
ALLOW_ROOT_LOGIN=false
SKIPUPDATE=false
SKIP_SSH_KEY_SETUP=false
SKIP_FAIL2BAN_SETUP=false

# File paths
UFW_RULES_FILE="/etc/ufw/before.rules"
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
        --skip-fail2ban-setup)
            SKIP_FAIL2BAN_SETUP=true
            shift
            ;;
        --allow-root-login)
            ALLOW_ROOT_LOGIN=true
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

	#Check if update is skipping
	if [ "$SKIPUPDATE" = true ]; then
		echo -e "$WARNING Skipped update becatuse of parameter --skip-update: $SKIPUPDATE"
		return
	fi
	
	#Update the System
	sudo apt update
	sudo apt upgrade -y
	clear
	echo -e "$OK System was sucsessfully updated"
	
}

create_user() {

	#Check if user already exist
	if id "$USERNAME" &>/dev/null; then
		echo -e "$WARNING User $USERNAME already exists, skipping."
		return
	fi
	
	#Create a user
	sudo useradd -m -s /bin/bash "$USERNAME"
	echo "$USERNAME:$PASSWORD" | sudo chpasswd
	sudo usermod -aG sudo "$USERNAME"
	echo -e "$OK User $USERNAME was successfully created."
	
}

setup_authorized_keys() {

	local user="$USERNAME"
    local ssh_dir="/home/$user/.ssh"
    local auth_keys="$ssh_dir/authorized_keys"

	#Check if ssh-key setup is skipping
	if [ "$SKIP_SSH_KEY_SETUP" = true ]; then
		echo -e "$WARNING SSH-key setup was skipped."
		return
	fi

	#Check if authorized_keys file is already exist
    if [[ -f "$auth_keys" ]] && \
       [[ "$(stat -c %a "$auth_keys")" == "600" ]] && \
       [[ "$(stat -c %a "$ssh_dir")" == "700" ]]; then
		sudo nano "$auth_keys"
        echo -e "$OK Authorized_keys already exists for $USERNAME with correct permissions."
		return
    fi
	
	#Creating an authorized_keys file
	sudo mkdir -p "$ssh_dir"
	sudo touch "$auth_keys"
	sudo chmod 700 "$ssh_dir"
	sudo chmod 600 "$auth_keys"
	sudo chown -R "$user:$user" "$ssh_dir"
	sudo nano "$auth_keys"
	echo -e "$OK Authorized_keys was successfully created for $USERNAME with correct permissions."
	
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
		exit 1
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
	
	#Adds a line AuthenticationMethods publickey after PasswordAuthentication line
	if grep -qE '^[[:space:]]*AuthenticationMethods[[:space:]]+publickey[[:space:]]*$' "$sshd_config"; then
		echo -e "$OK AuthenticationMethods publickey already exists."
	else
		sed -i '/^[[:space:]]*PasswordAuthentication[[:space:]]\+no[[:space:]]*$/a AuthenticationMethods publickey' "$$sshd_config"
		echo -e "$OK AuthenticationMethods publickey added in $sshd_config"
	fi
	
	echo -e "$OK SSH-password authentification was disabled"
	
}

change_permit_root_login() {
	
	#Check if root login was remain to enable
	if [ "$ALLOW_ROOT_LOGIN" = true ]; then
		echo -e "$WARNING Root login was remain available by flag: --allow-root-login"
		return
	fi
	
	#Disable root login
	sed -i "s|^#\?PermitRootLogin .*$|PermitRootLogin no|" \
		/etc/ssh/sshd_config
		
	echo -e "$OK Root login was disabled."
	
}

set_list_allow_users() {

	#Check if parameter is already exist
	if grep -qxF "AllowUsers $USERNAME" "$sshd_config_path"; then
		echo -e "$WARNING AllowUsers $USERNAME already exists as a parameter in $sshd_config_path"
		return
	fi
	
	#Add a parameter AllowUsers
	echo "AllowUsers $USERNAME" >> "$sshd_config_path"
	echo -e "$OK Login was enabled only for $USERNAME"

	#sudo sshd -T | egrep "allowusers|passwordauthentication|kbdinteractiveauthentication|pubkeyauthentication|authenticationmethods|permitrootlogin"
	
}

check_ufw_exist() {

	#Check if threre are ufw on system
	if [ ! command -v ufw &>/dev/null ]; then
		apt install -y ufw
	fi

	#Check if rules file exist
	if [ ! -e $UFW_RULES_FILE ]; then 
		echo -e "$ERROR $UFW_RULES_FILE does not exist."
		exit 1
	fi
	
}

disable_icmp() {

	#Reset ufw setting before setting up
	sudo ufw --force reset > /dev/null 2>&1

	# Change ACCEPT to DROP in icmp code for INPUT
	sed -i 's/-A ufw-before-input -p icmp --icmp-type destination-unreachable -j ACCEPT/-A ufw-before-input -p icmp --icmp-type destination-unreachable -j DROP/' "$UFW_RULES_FILE"
	sed -i 's/-A ufw-before-input -p icmp --icmp-type time-exceeded -j ACCEPT/-A ufw-before-input -p icmp --icmp-type time-exceeded -j DROP/' "$UFW_RULES_FILE"
	sed -i 's/-A ufw-before-input -p icmp --icmp-type parameter-problem -j ACCEPT/-A ufw-before-input -p icmp --icmp-type parameter-problem -j DROP/' "$UFW_RULES_FILE"
	sed -i 's/-A ufw-before-input -p icmp --icmp-type echo-request -j ACCEPT/-A ufw-before-input -p icmp --icmp-type echo-request -j DROP/' "$UFW_RULES_FILE"

	#Append a new string to rules
	sed -i '/-A ufw-before-input -p icmp --icmp-type echo-request -j DROP/a -A ufw-before-input -p icmp --icmp-type source-quench -j DROP' "$UFW_RULES_FILE"

	# Change ACCEPT to DROP in icmp code for FORWARD
	sed -i 's/-A ufw-before-forward -p icmp --icmp-type destination-unreachable -j ACCEPT/-A ufw-before-forward -p icmp --icmp-type destination-unreachable -j DROP/' "$UFW_RULES_FILE"
	sed -i 's/-A ufw-before-forward -p icmp --icmp-type time-exceeded -j ACCEPT/-A ufw-before-forward -p icmp --icmp-type time-exceeded -j DROP/' "$UFW_RULES_FILE"
	sed -i 's/-A ufw-before-forward -p icmp --icmp-type parameter-problem -j ACCEPT/-A ufw-before-forward -p icmp --icmp-type parameter-problem -j DROP/' "$UFW_RULES_FILE"
	sed -i 's/-A ufw-before-forward -p icmp --icmp-type echo-request -j ACCEPT/-A ufw-before-forward -p icmp --icmp-type echo-request -j DROP/' "$UFW_RULES_FILE"

	echo -e "$OK Server ping was disabled"
	
}

enable_ufw() {

	#Setting up an ufw
	sudo ufw default deny incoming > /dev/null 2>&1
	sudo ufw default allow outgoing > /dev/null 2>&1

	sudo ufw allow 80/tcp > /dev/null 2>&1
	sudo ufw allow 443/tcp > /dev/null 2>&1
	sudo ufw allow 443/udp > /dev/null 2>&1
	sudo ufw allow $SSHPORT/tcp > /dev/null 2>&1

	sudo ufw --force enable > /dev/null 2>&1

	echo -e "$OK UFW was configured and enabled"
	
}

enable_fail2ban() {

	local f2b_conf_path="/etc/fail2ban/jail.conf"
	local f2b_localconf_path="/etc/fail2ban/jail.local"

	if [ "$SKIP_SSH_KEY_SETUP" = true ]; then
		echo -e "$WARNING SSH-key setup was skipped."
		return
	fi

	#Check if threre are fail2ban on system
	if [ ! command -v fail2ban-client &>/dev/null ]; then
		echo -e "$OK Fail2ban is already installed"
	else
		echo -e "$WARNING Installing Fail2ban..."
		sudo apt install -y fail2ban
	fi
	
	#Check if fail2ban is already configured
	if [ -e $f2b_conf_path ]; then
		if [ -e $f2b_localconf_path ]; then
			echo -e "$WARNING File $f2b_localconf_path is already exist."
			return
		fi
	else
		echo -e "$ERROR No config file $f2b_conf_path. Abort installation."
		exit 1
	fi
	
	#Make a local conf file
	sudo touch $f2b_localconf_path
	
	#Writing custom configuration of fail2ban
    printf '%s\n' '[sshd]' 'enabled = true' 'maxretry = 3' 'findtime = 10m' 'bantime = 3h' > /etc/fail2ban/jail.local
	
	sudo systemctl enable --now fail2ban
	sudo systemctl restart fail2ban
	
	echo -e "$OK Fail2ban was configured and enabled (custom configuration file is $f2b_localconf_path)"
}

ssh_reload() {
	#Reload daemon to activate new SSH port
	sudo systemctl daemon-reload && sudo systemctl restart ssh
}

main(){

	#Clear console before all actions
	clear 
	
	update_system
	create_user
	setup_authorized_keys
	change_default_ssh_port
	change_password_authentication
	change_permit_root_login
	set_list_allow_users
	check_ufw_exist
	disable_icmp
	enable_ufw
	enable_fail2ban
	#ssh_reload
}

main
