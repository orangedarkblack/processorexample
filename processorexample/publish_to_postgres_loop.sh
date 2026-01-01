#!/usr/bin/env bash
# Inserta un usuario y una orden en Postgres cada 15 segundos
# Uso: bash publish_to_postgres_loop.sh

set -euo pipefail
WORKDIR="$(cd "$(dirname "$0")" && pwd)"
COMPOSE_FILE="$WORKDIR/docker-compose-full.yml"
LOGFILE="$WORKDIR/publish_postgres.log"

echo "Starting publisher loop (logs -> $LOGFILE)"

echo "---- $(date -u +%Y-%m-%dT%H:%M:%SZ) Publisher started ----" >> "$LOGFILE"

while true; do
  TS=$(date +%s)
  NAME="TestUser-${TS}"
  EMAIL="test.${TS}@example.com"
  PRODUCT="TestProduct-${TS}"
  AMOUNT=$(awk -v seed="$TS" 'BEGIN { srand(seed); printf("%.2f", (rand()*200)+1) }')

  SQL_USER="INSERT INTO users (name, email) VALUES ('$NAME', '$EMAIL');"
  # Insert user
  echo "[$(date +%T)] Inserting user: $NAME / $EMAIL" >> "$LOGFILE"
  docker-compose -f "$COMPOSE_FILE" exec -T postgres psql -U nifi -d nifi_db -c "$SQL_USER" >> "$LOGFILE" 2>&1 || {
    echo "[$(date +%T)] Error inserting user" >> "$LOGFILE"
  }

  # Get the last inserted user id (assumes id is serial)
  USER_ID=$(docker-compose -f "$COMPOSE_FILE" exec -T postgres psql -U nifi -d nifi_db -t -A -c "SELECT id FROM users ORDER BY id DESC LIMIT 1;" | tr -d '\r\n' || true)
  if [ -z "$USER_ID" ]; then
    echo "[$(date +%T)] Could not obtain user id, skipping order insert" >> "$LOGFILE"
  else
    SQL_ORDER="INSERT INTO orders (user_id, product, amount) VALUES ($USER_ID, '$PRODUCT', $AMOUNT);"
    echo "[$(date +%T)] Inserting order for user $USER_ID: $PRODUCT ($AMOUNT)" >> "$LOGFILE"
    docker-compose -f "$COMPOSE_FILE" exec -T postgres psql -U nifi -d nifi_db -c "$SQL_ORDER" >> "$LOGFILE" 2>&1 || {
      echo "[$(date +%T)] Error inserting order" >> "$LOGFILE"
    }
  fi

  echo "[$(date +%T)] Inserted user($UID) and order (if any)" >> "$LOGFILE"
  sleep 15
done
