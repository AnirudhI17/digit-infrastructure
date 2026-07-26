#!/bin/bash
set -e

# ==============================================================================
# Kafka Topic Creation Helper Script
# ==============================================================================
# Pre-creates required topics for DIGIT microservices on startup.

BOOTSTRAP_SERVER=${KAFKA_BOOTSTRAP_SERVERS:-"localhost:9092"}
PARTITIONS=${KAFKA_NUM_PARTITIONS:-3}
REPLICATION_FACTOR=${KAFKA_DEFAULT_REPLICATION_FACTOR:-1}

# List of common DIGIT microservice topics (Fallback defaults)
TOPICS=(
    "egov-notification-sms"
    "egov-notification-mail"
    "save-user-details"
    "update-user-details"
    "egov-telemetry-data"
    "payment-create-db"
    "collection-services-payment-receipt"
)

# Dynamically load from shared config if present
TOPIC_FILE="/config/kafka/topics.txt"
if [ -f "$TOPIC_FILE" ]; then
    echo "Loading topic definitions dynamically from $TOPIC_FILE..."
    mapfile -t FILE_TOPICS < <(grep -v '^#' "$TOPIC_FILE" | grep -v '^[[:space:]]*$')
    if [ ${#FILE_TOPICS[@]} -gt 0 ]; then
        TOPICS=("${FILE_TOPICS[@]}")
    fi
fi

echo "Waiting for Kafka to be ready at ${BOOTSTRAP_SERVER}..."
until kafka-topics.sh --bootstrap-server "$BOOTSTRAP_SERVER" --list > /dev/null 2>&1; do
  sleep 2
done

echo "Kafka is active. Checking and provisioning default DIGIT topics..."

for topic in "${TOPICS[@]}"; do
  # Check if topic exists
  if kafka-topics.sh --bootstrap-server "$BOOTSTRAP_SERVER" --describe --topic "$topic" > /dev/null 2>&1; then
    echo "Topic '$topic' already exists. Skipping."
  else
    echo "Creating topic '$topic' with $PARTITIONS partitions..."
    kafka-topics.sh --bootstrap-server "$BOOTSTRAP_SERVER" \
      --create --topic "$topic" \
      --partitions "$PARTITIONS" \
      --replication-factor "$REPLICATION_FACTOR"
  fi
done

echo "Topic provisioning complete!"
