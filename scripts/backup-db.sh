#!/bin/bash
# ==============================================================================
# Database Backup Script for DIGIT PostgreSQL
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load Environment variables
if [ -f "$ROOT_DIR/.env" ]; then
    export $(grep -v '^#' "$ROOT_DIR/.env" | xargs)
fi

DB_USER=${POSTGRES_USER:-postgres}
DB_NAME=${POSTGRES_DB:-digit_db}
BACKUP_DIR="$ROOT_DIR/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0;m' # No Color

mkdir -p "$BACKUP_DIR"

# Check if postgres container is running
if [ "$(docker inspect --format='{{.State.Status}}' digit-postgres 2>/dev/null)" != "running" ]; then
    echo -e "${RED}Error: digit-postgres container is not running. Start it before taking backups.${NC}"
    exit 1
fi

echo -e "${YELLOW}Starting PostgreSQL Backup...${NC}"

# Backup Option 1: Back up all databases (Default)
ALL_BACKUP_FILE="$BACKUP_DIR/digit_all_databases_$TIMESTAMP.sql"
echo "Creating backup for all databases..."

docker exec -t digit-postgres pg_dumpall -U "$DB_USER" > "$ALL_BACKUP_FILE"

if [ $? -eq 0 ]; then
    # Compress the output file to save space
    gzip "$ALL_BACKUP_FILE"
    echo -e "${GREEN}[✔] Full backup created successfully: ${ALL_BACKUP_FILE}.gz${NC}"
else
    echo -e "${RED}[✘] Backup failed.${NC}"
    exit 1
fi

# Backup Option 2: Back up individual databases if requested as an argument
if [ -n "$1" ]; then
    TARGET_DB=$1
    SINGLE_BACKUP_FILE="$BACKUP_DIR/${TARGET_DB}_$TIMESTAMP.sql"
    echo "Creating backup for targeted database: $TARGET_DB..."
    
    docker exec -t digit-postgres pg_dump -U "$DB_USER" -d "$TARGET_DB" -F c > "$SINGLE_BACKUP_FILE"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[✔] Database '$TARGET_DB' backup created successfully: ${SINGLE_BACKUP_FILE}${NC}"
    else
        echo -e "${RED}[✘] Database '$TARGET_DB' backup failed.${NC}"
    fi
fi

exit 0
