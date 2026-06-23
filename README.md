# Quick Install

```bash
bash <(curl -Ls https://raw.githubusercontent.com/MatveyPopov1306/rm-bash-install/main/basic-prepare.sh)
```

## Installation with paremeters

```bash
bash <(curl -Ls https://raw.githubusercontent.com/MatveyPopov1306/rm-bash-install/main/basic-prepare.sh) --port 10122
```

## Remnawave panel installation
```bash
bash <(curl -Ls https://raw.githubusercontent.com/MatveyPopov1306/rm-bash-install/main/rm-panel-install.sh) 
```

```bash
curl -fsSL -H "Cache-Control: no-cache" \
"https://raw.githubusercontent.com/MatveyPopov1306/rm-bash-install/main/rm-panel-install.sh" \
| bash -s -- --domain mydomain.com --subdomain mysubdomain.com
```
