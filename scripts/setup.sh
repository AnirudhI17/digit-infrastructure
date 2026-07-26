#!/bin/bash
# ==============================================================================
# Setup & Launch Script for DIGIT Infrastructure
# ==============================================================================

# Determine directory of this script to run relative commands
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0;m' # No Color

echo -e "${YELLOW}Starting DIGIT Infrastructure setup sequence...${NC}"

# 1. Run validation
if [ -f "$SCRIPT_DIR/validate.sh" ]; then
    bash "$SCRIPT_DIR/validate.sh" || { echo -e "${RED}Validation checks failed. Exiting.${NC}"; exit 1; }
else
    echo -e "${RED}validate.sh not found. Exiting.${NC}"
    exit 1
fi

# 2. Run bootstrap
if [ -f "$SCRIPT_DIR/bootstrap.sh" ]; then
    cd "$ROOT_DIR"
    bash "$SCRIPT_DIR/bootstrap.sh" || { echo -e "${RED}Bootstrap sequence failed. Exiting.${NC}"; exit 1; }
else
    echo -e "${RED}bootstrap.sh not found. Exiting.${NC}"
    exit 1
fi

# 3. Start containers
echo -e "${YELLOW}Launching infrastructure containers via Docker Compose...${NC}"
docker compose -f "$ROOT_DIR/docker-compose.infrastructure.yml" up -d

# 4. Wait and provision Kafka topics
echo -e "${YELLOW}Waiting for Kafka to start to provision topics...${NC}"
sleep 5
docker exec -t digit-kafka /scripts/create-topics.sh || true

# 5. Initialize Elasticsearch Index Mappings
if [ -f "$SCRIPT_DIR/init-elasticsearch.sh" ]; then
    echo -e "${YELLOW}Initializing Elasticsearch Index Mappings...${NC}"
    bash "$SCRIPT_DIR/init-elasticsearch.sh" || true
fi

echo -e "${GREEN}DIGIT Infrastructure setup successfully launched!${NC}"
echo -e "Run ${YELLOW}./scripts/healthcheck.sh${NC} to check execution status."
exit 0
