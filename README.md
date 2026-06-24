# Quick Install

## Basic update VM before installation
```bash
bash <(curl -Ls https://raw.githubusercontent.com/MatveyPopov1306/rm-bash-install/main/basic-prepare.sh)
```

Don't forget to close ports on remnawave node
```bash
sudo ufw allow from YOUR_PANEL_IP to any port YOUR_NODE_PORT proto tcp
sudo ufw deny YOUR_NODE_PORT/tcp
sudo ufw reload
```

## Installation with paremeters
Note: if you don't provide any arguments to installation script, the custom port would be "10122"
```bash
bash <(curl -Ls https://raw.githubusercontent.com/MatveyPopov1306/rm-bash-install/main/basic-prepare.sh) --port 10122
```

## Remnawave panel installation
Note: it's necessary to provide domain and subdomain addreses
```bash
bash <(curl -Ls https://raw.githubusercontent.com/MatveyPopov1306/rm-bash-install/main/rm-panel-install.sh) --domain PLACE_YOUR_DOMAIN --subdomain PLACE_YOUR_SUBDOMAIN
```

