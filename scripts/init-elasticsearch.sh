#!/bin/bash
# ==============================================================================
# Elasticsearch Auto-Initialization Script
# ==============================================================================
# Waits for Elasticsearch to become responsive, then applies all index schemas
# defined in the shared mappings configuration folder.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load Environment variables
if [ -f "$ROOT_DIR/.env" ]; then
    export $(grep -v '^#' "$ROOT_DIR/.env" | xargs)
fi

ES_PORT=${ELASTICSEARCH_PORT:-9200}
ES_HOST="localhost"
ES_URL="http://${ES_HOST}:${ES_PORT}"
MAPPINGS_DIR="$ROOT_DIR/shared/config/elasticsearch/mappings"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0;m' # No Color

echo -e "${YELLOW}Waiting for Elasticsearch to become ready at ${ES_URL}...${NC}"

until curl -s "$ES_URL" > /dev/null; do
    sleep 3
done

echo -e "${GREEN}Elasticsearch is ready. Provisioning indexes...${NC}"

if [ -d "$MAPPINGS_DIR" ]; then
    for mapping_file in $(find "$MAPPINGS_DIR" -maxdepth 1 -name "*.json" -type f | sort); do
        filename=$(basename "$mapping_file")
        index_name="${filename%.*}" # strip extension
        
        echo -e "Checking if index ${YELLOW}'$index_name'${NC} exists..."
        
        # Check index status
        STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$ES_URL/$index_name")
        
        if [ "$STATUS_CODE" -eq 200 ]; then
            echo -e "  Index '$index_name' already exists. Skipping mapping update."
        else
            echo -e "  Index '$index_name' not found. Creating index and applying mapping..."
            RESPONSE=$(curl -s -X PUT "$ES_URL/$index_name" \
                -H "Content-Type: application/json" \
                -d @"$mapping_file")
                
            if echo "$RESPONSE" | grep -q '"acknowledged":true'; then
                echo -e "  ${GREEN}[✔] Successfully provisioned index: $index_name${NC}"
            else
                echo -e "  ${RED}[✘] Failed to provision index: $index_name. Response: $RESPONSE${NC}"
            fi
        fi
    done
else
    echo "Mappings directory '$MAPPINGS_DIR' not found."
fi

echo -e "${GREEN}Elasticsearch mappings initialization complete.${NC}"
exit 0
