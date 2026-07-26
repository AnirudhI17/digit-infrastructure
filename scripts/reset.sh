#!/bin/bash
# ==============================================================================
# Reset Script for DIGIT Infrastructure
# ==============================================================================
# Stops containers, deletes docker volumes, and cleans up local host storage data.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0;m' # No Color

echo -e "${RED}WARNING: This will destroy all infrastructure containers, named volumes, and local database caches.${NC}"
read -p "Are you sure you want to proceed? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Reset cancelled."
    exit 0
fi

echo -e "${YELLOW}Stopping and removing Docker containers and named volumes...${NC}"
docker compose -f "$ROOT_DIR/docker-compose.infrastructure.yml" down -v --remove-orphans

echo -e "${YELLOW}Removing host data mount folders (data/)...${NC}"
if [ -d "$ROOT_DIR/data" ]; then
    rm -rf "$ROOT_DIR/data"
    echo -e "${GREEN}[✔] Host directory data/ deleted.${NC}"
else
    echo "No host data directory found."
fi

# Clean local environment file
if [ -f "$ROOT_DIR/.env" ]; then
    read -p "Do you want to delete the local .env configuration file as well? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -f "$ROOT_DIR/.env"
        echo -e "${GREEN}[✔] .env file deleted.${NC}"
    fi
fi

echo -e "${GREEN}DIGIT Infrastructure successfully reset.${NC}"
exit 0
