#!/bin/bash
# ==============================================================================
# Health Check Verification Script for DIGIT Infrastructure
# ==============================================================================
# Verifies container runtime status, healthcheck parameters, and port availability.

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0;m' # No Color

echo -e "${YELLOW}Checking running containers health status...${NC}"

CONTAINERS=("digit-postgres" "digit-zookeeper" "digit-kafka" "digit-redis" "digit-elasticsearch")

# Helper function to get container health
get_container_health() {
    local container_name=$1
    
    # Check if container is running
    local status=$(docker inspect --format='{{.State.Status}}' "$container_name" 2>/dev/null)
    
    if [ -z "$status" ]; then
        echo -e "${RED}NOT CREATED${NC}"
        return 1
    fi

    if [ "$status" != "running" ]; then
        echo -e "${RED}DOWN (Status: $status)${NC}"
        return 1
    fi

    # Check Docker Health status if defined
    local health=$(docker inspect --format='{{.State.Health.Status}}' "$container_name" 2>/dev/null)
    
    if [ -z "$health" ] || [ "$health" == "<nil>" ]; then
        # No health check defined in image/compose, but container is running
        echo -e "${GREEN}RUNNING (No health check defined)${NC}"
    elif [ "$health" == "healthy" ]; then
        echo -e "${GREEN}HEALTHY${NC}"
    else
        echo -e "${YELLOW}UNHEALTHY / STARTING (Health: $health)${NC}"
    fi
}

for container in "${CONTAINERS[@]}"; do
    echo -n -e "Container ${YELLOW}$container${NC}: "
    get_container_health "$container"
done

# Detailed checks using exec connections
echo -e "\n${YELLOW}Running inside-container connection validations...${NC}"

# 1. PostgreSQL check
if docker exec digit-postgres pg_isready -q; then
    echo -e "PostgreSQL Server: ${GREEN}Responsive${NC}"
else
    echo -e "PostgreSQL Server: ${RED}Not Responsive${NC}"
fi

# 2. Redis check
if [ "$(docker exec digit-redis redis-cli ping)" == "PONG" ]; then
    echo -e "Redis Cache Store: ${GREEN}Responsive${NC}"
else
    echo -e "Redis Cache Store: ${RED}Not Responsive${NC}"
fi

# 3. Elasticsearch check
ES_HEALTH=$(docker exec digit-elasticsearch curl -s -o /dev/null -w "%{http_code}" http://localhost:9200)
if [ "$ES_HEALTH" -eq 200 ]; then
    echo -e "Elasticsearch Indexer: ${GREEN}Responsive (200 OK)${NC}"
else
    echo -e "Elasticsearch Indexer: ${RED}Not Responsive (HTTP Status: $ES_HEALTH)${NC}"
fi

# 4. Kafka Topics check
if docker exec digit-kafka kafka-topics.sh --bootstrap-server localhost:9092 --list >/dev/null 2>&1; then
    echo -e "Kafka Message Broker: ${GREEN}Responsive${NC}"
else
    echo -e "Kafka Message Broker: ${RED}Not Responsive / Standby${NC}"
fi

echo -e "\n${GREEN}Health checks completed.${NC}"
exit 0
