#!/bin/bash

# === Settings ===
CRON_USER="sftpuser"                       # User for whom the cron job is being set
SCRIPT_PATH="/home/sftpuser/scripts/script.sh"  # Path to the script that should run
CRON_SCHEDULE="*/5 * * * *"               # Cron schedule (every 5 minutes)

# === Create a secure temporary file for editing the crontab ===
TEMP_FILE=$(mktemp) || {
    echo "Error: Could not create a temporary file." >&2
    exit 1
}

# === Ensure the temp file is removed on script exit ===
trap 'rm -f "$TEMP_FILE"' EXIT

# === Fetch the current crontab for the user (if any) ===
crontab -u "$CRON_USER" -l > "$TEMP_FILE" 2>/dev/null

# === Check if the cron job already exists ===
if grep -Fq "$SCRIPT_PATH" "$TEMP_FILE"; then
    echo "Cron job already exists for $SCRIPT_PATH."
    exit 0
fi

# === Append the new cron job to the temp file ===
echo "$CRON_SCHEDULE $SCRIPT_PATH >> /home/sftpuser/cron.log 2>&1" >> "$TEMP_FILE"

# === Install the updated crontab ===
if crontab -u "$CRON_USER" "$TEMP_FILE"; then
    echo "Cron job added successfully (runs every 5 minutes)."
else
    echo "Error: Failed to update crontab for user '$CRON_USER'!" >&2
    exit 1
fi

