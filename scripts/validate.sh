#!/bin/bash
# ==============================================================================
# Environment Validation Script for DIGIT Infrastructure
# ==============================================================================
# This script runs pre-requisite checks on the developer workstation.

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0;m' # No Color

echo -e "${YELLOW}Starting validation checks for DIGIT Infrastructure...${NC}"

# Check Docker installation
if command -v docker >/dev/null 2>&1; then
    echo -e "${GREEN}[✔] Docker is installed: $(docker --version)${NC}"
else
    echo -e "${RED}[✘] Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

# Check Docker Compose installation
if command -v docker-compose >/dev/null 2>&1; then
    echo -e "${GREEN}[✔] Docker Compose is installed: $(docker-compose --version)${NC}"
elif docker compose version >/dev/null 2>&1; then
    echo -e "${GREEN}[✔] Docker Compose (v2 Plugin) is installed: $(docker compose version)${NC}"
else
    echo -e "${RED}[✘] Docker Compose is not found. Please install Docker Compose.${NC}"
    exit 1
fi

# Check Minimum RAM recommendation (16GB)
# This check operates slightly differently on macOS vs Linux vs WSL/Windows Git Bash
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    TOTAL_MEM=$(free -g | awk '/^Mem:/{print $2}')
    if [ "$TOTAL_MEM" -lt 12 ]; then
        echo -e "${YELLOW}[!] Warning: You have ${TOTAL_MEM}GB RAM. 16GB is recommended to run all DIGIT services smoothly.${NC}"
    else
        echo -e "${GREEN}[✔] Sufficient system memory detected: ${TOTAL_MEM}GB RAM.${NC}"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    TOTAL_MEM=$(sysctl hw.memsize | awk '{print $2/1073741824}')
    if (( $(echo "$TOTAL_MEM < 12" | bc -l) )); then
        echo -e "${YELLOW}[!] Warning: You have ${TOTAL_MEM}GB RAM. 16GB is recommended.${NC}"
    else
        echo -e "${GREEN}[✔] Sufficient system memory detected: ${TOTAL_MEM}GB RAM.${NC}"
    fi
else
    echo -e "${YELLOW}[!] OS system memory check skipped. Please verify you have at least 16GB memory total.${NC}"
fi

# Verify folder configuration structure
REQUIRED_DIRS=("postgres/config" "postgres/init" "kafka/zookeeper" "kafka/broker" "redis" "elasticsearch/config")
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "${GREEN}[✔] Repository structure: '$dir' exists.${NC}"
    else
        echo -e "${RED}[✘] Missing repository folder: '$dir'. Please check out repository files completely.${NC}"
        exit 1
    fi
done

echo -e "${GREEN}Environment validation complete! You are ready to proceed.${NC}"
exit 0
