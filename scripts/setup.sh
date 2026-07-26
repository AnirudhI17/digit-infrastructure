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
echo -e "${YELLOW}Provisioning defaults...${NC}"
if [ -f "$ROOT_DIR/kafka/scripts/create-topics.sh" ]; then
    # Run the topic provisioner in the context of the running kafka container or locally
    # We run it via container exec since host might not have kafka-topics.sh CLI installed.
    echo "Waiting for Kafka container to execute topic setup..."
    # Sleep a bit for broker startup
    sleep 5
    docker exec -it digit-kafka /bin/bash -c "/var/lib/kafka/data/../../../../../../../host_or_target/not_exists" 2>/dev/null || true
    # A cleaner approach is copying the script or running it via standard broker exec
    docker exec -d digit-kafka /bin/bash -c "KAFKA_BOOTSTRAP_SERVERS=localhost:9092 /var/lib/kafka/data/../../../../usr/bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic egov-notification-sms --partitions 3 --replication-factor 1" || true
    # Actually, we can copy or mount the kafka scripts into container and exec them:
    # Our docker-compose file mounts kafka_data to /var/lib/kafka/data.
    # To run topics provisioning, we can just run it using exec:
    docker exec -t digit-kafka kafka-topics.sh --bootstrap-server localhost:9092 --create --topic egov-notification-sms --partitions 3 --replication-factor 1 --if-not-exists || true
    docker exec -t digit-kafka kafka-topics.sh --bootstrap-server localhost:9092 --create --topic egov-notification-mail --partitions 3 --replication-factor 1 --if-not-exists || true
    docker exec -t digit-kafka kafka-topics.sh --bootstrap-server localhost:9092 --create --topic save-user-details --partitions 3 --replication-factor 1 --if-not-exists || true
    docker exec -t digit-kafka kafka-topics.sh --bootstrap-server localhost:9092 --create --topic update-user-details --partitions 3 --replication-factor 1 --if-not-exists || true
    docker exec -t digit-kafka kafka-topics.sh --bootstrap-server localhost:9092 --create --topic egov-telemetry-data --partitions 3 --replication-factor 1 --if-not-exists || true
fi

echo -e "${GREEN}DIGIT Infrastructure setup successfully launched!${NC}"
echo -e "Run ${YELLOW}./scripts/healthcheck.sh${NC} to check execution status."
exit 0
