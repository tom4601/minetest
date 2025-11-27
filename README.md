# LuantiServer - Infrastructure de monitoring

Solution complète d'hébergement et de monitoring pour serveurs Luanti multi-environnements.

## Description

Ce projet propose une infrastructure d'hébergement de serveurs Luanti avec un système de monitoring en temps réel accessible via interface web sécurisée SSL.

## Architecture

- 1 serveur hôte
- 4 conteneurs LXC isolés
- 5 environnements de jeu distincts
- Dashboard web de monitoring
- Automatisation complète

## Fonctionnalités

- Monitoring en temps réel de l'état des services
- Suivi des derniers redémarrages
- Interface web responsive et sécurisée (HTTPS)
- Collecte automatique des données toutes les 30 secondes
- Support multi-conteneurs LXC

## Stack technique

- **Conteneurisation** : LXC
- **Web Server** : Nginx
- **Scripting** : Bash
- **Frontend** : HTML5, CSS3, JavaScript (Vanilla)
- **Automatisation** : Systemd, Cron

## Prérequis

- Debian/Ubuntu Linux
- Nginx
- LXC
- Python3 (pour validation JSON)
- Certbot (pour SSL)

## Installation

### 1. Cloner le repository

```bash
git clone https://github.com/votre-username/luantiserver.git
cd luantiserver
```

### 2. Installer les dépendances

```bash
sudo apt update
sudo apt install nginx lxc python3  python3-certbot-nginx -y
```

### 3. Configurer les conteneurs LXC

Créez 4 conteneurs LXC nommés : `creatif`, `exploration`, `survie`, `custom`

```bash
# Exemple pour un conteneur
lxc-create -n creatif -t download -- -d debian -r bookworm -a amd64
```

### 4. Installer les scripts de monitoring

```bash
sudo mkdir -p /opt/luanti-monitor
sudo cp scripts/collect_stats.sh /opt/luanti-monitor/
sudo chmod +x /opt/luanti-monitor/collect_stats.sh
```

### 5. Configurer Nginx

```bash
sudo cp nginx/luanti-monitor /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/luanti-monitor /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### 6. Installer l'interface web

```bash
sudo mkdir -p /var/www/luanti-monitor/data
sudo cp web/index.html /var/www/luanti-monitor/
sudo chown -R www-data:www-data /var/www/luanti-monitor
```

### 7. Configurer l'automatisation

```bash
sudo crontab -e
```

Ajoutez ces lignes :
```
* * * * * /opt/luanti-monitor/collect_stats.sh
* * * * * sleep 30; /opt/luanti-monitor/collect_stats.sh
```


