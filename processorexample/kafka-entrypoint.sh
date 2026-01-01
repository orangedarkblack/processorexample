#!/bin/bash
set -e

# Start Kafka in background
/etc/confluent/docker/run &
KAFKA_PID=$!

# Wait for Kafka to be ready
echo "Waiting for Kafka broker to be ready..."
for i in {1..60}; do
  if kafka-broker-api-versions --bootstrap-server localhost:9092 2>/dev/null || kafka-topics --bootstrap-server localhost:9092 --list > /dev/null 2>&1; then
    echo "Kafka broker is ready!"
    sleep 2
    break
  fi
  echo "Attempt $i/60: Waiting for Kafka..."
  sleep 2
done

# Create topics
echo "Creating Kafka topics..."
kafka-topics --bootstrap-server localhost:9092 --create --if-not-exists --topic users-topic --partitions 1 --replication-factor 1 || true
kafka-topics --bootstrap-server localhost:9092 --create --if-not-exists --topic orders-topic --partitions 1 --replication-factor 1 || true

echo "Topics created successfully!"
echo "Listing topics:"
kafka-topics --bootstrap-server localhost:9092 --list

# Keep the process running
wait $KAFKA_PID
