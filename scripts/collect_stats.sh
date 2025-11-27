#!/bin/bash

# Script de monitoring simplifié pour serveurs Luanti
# Collecte uniquement : état de santé et dernier redémarrage

# Configuration
OUTPUT_DIR="/var/www/luanti-monitor/data"
OUTPUT_FILE="$OUTPUT_DIR/stats.json"

# Conteneurs LXC
declare -A CONTAINERS=(
    ["hote"]="30000"
    ["creatif"]="30001"
    ["exploration"]="30002"
    ["survie"]="30003"
    ["custom"]="30004"
)

declare -A CONTAINER_NAMES=(
    ["hote"]="Monde Classique (Vanilla)"
    ["creatif"]="Monde Créatif"
    ["exploration"]="Monde Exploration"
    ["survie"]="Monde Survie (VoxelLibre)"
    ["custom"]="Monde Personnalisé"
)

# Créer le répertoire de sortie si nécessaire
mkdir -p "$OUTPUT_DIR"

# Fonction pour obtenir le statut d'un service
get_service_status() {
    local container=$1
    local status
    
    if [ "$container" == "hote" ]; then
        status=$(systemctl is-active minetest-server.service 2>/dev/null)
    else
        status=$(lxc-attach -n "$container" -- systemctl is-active minetest-server.service 2>/dev/null)
    fi
    
    echo "${status:-inactive}"
}

# Fonction pour obtenir la date du dernier redémarrage
get_last_restart() {
    local container=$1
    local timestamp
    
    if [ "$container" == "hote" ]; then
        timestamp=$(systemctl show -p ActiveEnterTimestamp minetest-server.service --value 2>/dev/null)
    else
        timestamp=$(lxc-attach -n "$container" -- systemctl show -p ActiveEnterTimestamp minetest-server.service --value 2>/dev/null)
    fi
    
    if [ -n "$timestamp" ] && [ "$timestamp" != "" ]; then
        echo "$timestamp"
    else
        echo "Jamais demarre"
    fi
}

# Variables pour le JSON
TIMESTAMP=$(date -Iseconds)
HOSTNAME=$(hostname)
UPTIME=$(uptime -p | sed 's/up //')

# Début du JSON
echo "{" > "$OUTPUT_FILE"
echo "  \"timestamp\": \"$TIMESTAMP\"," >> "$OUTPUT_FILE"
echo "  \"server_hostname\": \"$HOSTNAME\"," >> "$OUTPUT_FILE"
echo "  \"server_uptime\": \"$UPTIME\"," >> "$OUTPUT_FILE"
echo "  \"worlds\": [" >> "$OUTPUT_FILE"

# Parcourir les mondes
first=true
for container in hote creatif exploration survie custom; do
    port="${CONTAINERS[$container]}"
    name="${CONTAINER_NAMES[$container]}"
    
    # Récupérer les informations
    status=$(get_service_status "$container")
    last_restart=$(get_last_restart "$container")
    
    # Ajouter la virgule entre les éléments
    if [ "$first" = false ]; then
        echo "," >> "$OUTPUT_FILE"
    fi
    first=false
    
    # Écrire les données du monde (tout sur une ligne pour éviter les problèmes)
    echo -n "    {\"name\": \"$name\", \"container\": \"$container\", \"port\": $port, \"status\": \"$status\", \"last_restart\": \"$last_restart\"}" >> "$OUTPUT_FILE"
done

# Fermer le JSON
echo "" >> "$OUTPUT_FILE"
echo "  ]" >> "$OUTPUT_FILE"
echo "}" >> "$OUTPUT_FILE"

# Définir les bonnes permissions
chmod 644 "$OUTPUT_FILE"

echo "Monitoring data updated successfully at $(date)"
