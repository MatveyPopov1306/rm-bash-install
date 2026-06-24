# Quick Install

## Basic update VM before installation
```bash
bash <(curl -Ls https://raw.githubusercontent.com/MatveyPopov1306/rm-bash-install/main/basic-prepare.sh)
```

## Installation with paremeters
Note: if you don't provide any arguments to installation script, the custom port would be "10122"
```bash
bash <(curl -Ls https://raw.githubusercontent.com/MatveyPopov1306/rm-bash-install/main/basic-prepare.sh) --port 10122
```

## Remnawave panel installation
```bash
bash <(curl -Ls https://raw.githubusercontent.com/MatveyPopov1306/rm-bash-install/main/rm-panel-install.sh) --domain PLACE_YOUR_DOMAIN --subdomain PLACE_YOUR_SUBDOMAIN
```

