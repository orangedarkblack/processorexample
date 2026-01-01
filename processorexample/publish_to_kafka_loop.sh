#!/usr/bin/env bash
# Publica un usuario y una orden en los topics Kafka `users` y `orders` cada 15 segundos

set -euo pipefail
LOGFILE="/app/publish_kafka.log"
KAFKA_BROKER="kafka:29092"
USERS_TOPIC="users-topic"
ORDERS_TOPIC="orders-topic"

echo "Starting Kafka publisher loop (logs -> $LOGFILE)"
echo "---- $(date -u +%Y-%m-%dT%H:%M:%SZ) Kafka publisher started ----" >> "$LOGFILE"

while true; do
  TS=$(date +%s)
  NAME="TestUser-${TS}"
  EMAIL="test.${TS}@example.com"
  AGE=$((RANDOM % 50 + 18))  # Random age 18-67
  CITY="City-${TS}"
  PRODUCT="TestProduct-${TS}"
  AMOUNT=$(awk -v seed="$TS" 'BEGIN { srand(seed); printf("%.2f", (rand()*200)+1) }')

  # Construir JSON simples
  USER_JSON=$(printf '{"id":%s,"name":"%s","email":"%s","age":%s,"city":"%s","created_at":"%s"}' "$TS" "$NAME" "$EMAIL" "$AGE" "$CITY" "$(date -u +%Y-%m-%dT%H:%M:%SZ)")
  ORDER_JSON=$(printf '{"id":%s,"user_id":%s,"product":"%s","amount":%s,"status":"pending","created_at":"%s"}' "$((TS+1))" "$TS" "$PRODUCT" "$AMOUNT" "$(date -u +%Y-%m-%dT%H:%M:%SZ)")

  echo "[$(date +%T)] Publishing to topic '$USERS_TOPIC': $USER_JSON" >> "$LOGFILE"
  printf '%s\n' "$USER_JSON" | kafka-console-producer --bootstrap-server "$KAFKA_BROKER" --topic "$USERS_TOPIC" >> "$LOGFILE" 2>&1 || {
    echo "[$(date +%T)] Error publishing to '$USERS_TOPIC'" >> "$LOGFILE"
  }

  echo "[$(date +%T)] Publishing to topic '$ORDERS_TOPIC': $ORDER_JSON" >> "$LOGFILE"
  printf '%s\n' "$ORDER_JSON" | kafka-console-producer --bootstrap-server "$KAFKA_BROKER" --topic "$ORDERS_TOPIC" >> "$LOGFILE" 2>&1 || {
    echo "[$(date +%T)] Error publishing to '$ORDERS_TOPIC'" >> "$LOGFILE"
  }

  echo "[$(date +%T)] Published user and order (if no errors)" >> "$LOGFILE"
  sleep 15
done
