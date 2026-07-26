#!/bin/bash
# ==============================================================================
# Environment Bootstrap Script for DIGIT Infrastructure
# ==============================================================================
# Prepares the workspace for execution: copies environment files and creates data 
# mounts with correct permissions before container initialization.

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0;m' # No Color

echo -e "${YELLOW}Bootstrapping local DIGIT Infrastructure...${NC}"

# 1. Environment files configuration
if [ ! -f ".env" ]; then
    echo "Creating .env file from .env.example..."
    cp .env.example .env
    echo -e "${GREEN}[✔] Created .env successfully.${NC}"
else
    echo -e "${YELLOW}[!] .env already exists. Skipping creation to preserve your overrides.${NC}"
fi

# 2. Local Mount Directory Provisioning
# We pre-create these directories so they are owned by the current host user 
# instead of root (which occurs when Docker daemon creates missing mounts automatically)
echo "Creating local mount data directories..."
DATA_DIRS=(
    "data/postgres"
    "data/zookeeper/data"
    "data/zookeeper/log"
    "data/kafka/data"
    "data/redis"
    "data/elasticsearch"
)

for dir in "${DATA_DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo -e "${GREEN}[✔] Created local storage directory: $dir${NC}"
    else
        echo "Local storage directory already exists: $dir"
    fi
done

# Set permissions (specifically Elasticsearch requires strict owner permissions)
chmod -R 777 data/

echo -e "${GREEN}Bootstrap completed successfully! Run docker compose up when orchestration config is available.${NC}"
exit 0
