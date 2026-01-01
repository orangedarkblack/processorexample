#!/bin/bash

# This script performs a periodic sync:
# 1. Deletes specific analyzer folders.
# 2. Increments a counter.
# 3. Commits all changes with the counter in the message.
# 4. Pushes the changes to the 'main' branch on 'origin'.

set -uo pipefail # Exit on unset variables and errors

# --- Configuration ---
FOLDERS_TO_DELETE=(
    "processorexample/db-analyzer"
    "processorexample/doc-online-analyzer"
    "processorexample/wiki-analyzer"
)
COUNTER_FILE="sync_counter.txt"
COMMIT_MESSAGE_PREFIX="Auto-sync counter: "
SLEEP_INTERVAL=600 # 10 minutes in seconds

# --- Main Loop ---
echo "Starting periodic sync script. Press Ctrl+C to stop."

while true; do
    echo "-----------------------------------------------------"
    echo "Cycle started at: $(date)"

    # --- Deletion Phase ---
    echo "[SYNC] Deleting analyzer folders..."
    for folder in "${FOLDERS_TO_DELETE[@]}"; do
        if [ -d "$folder" ]; then
            echo "[SYNC]   - Deleting '$folder'"
            rm -rf "$folder"
        else
            echo "[SYNC]   - Folder '$folder' not found. Skipping."
        fi
    done

    # --- Counter Phase ---
    echo "[SYNC] Updating sync counter..."
    if [ ! -f "$COUNTER_FILE" ]; then
        counter=1
    else
        counter=$(<"$COUNTER_FILE")
        ((counter++))
    fi
    echo "$counter" > "$COUNTER_FILE"
    echo "[SYNC]   - New counter value: $counter"

    # --- Git Phase ---
    echo "[SYNC] Committing and pushing changes to Git..."
    # Add all changes (deletions and the counter file)
    git add .

    # Commit the changes. The counter file ensures there's always something to commit.
    git commit -m "$COMMIT_MESSAGE_PREFIX$counter"

    # Push to the remote repository
    echo "[SYNC] Pushing to origin main..."
    git push origin main

    echo "[SYNC] Cycle complete. Waiting for ${SLEEP_INTERVAL} seconds..."
    sleep "$SLEEP_INTERVAL"
done
