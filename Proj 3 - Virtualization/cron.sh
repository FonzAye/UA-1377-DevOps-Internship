#!/bin/bash

# Settings
CRON_USER="$USER"                 # Or use "sftpuser" if needed
SCRIPT_PATH="/home/sftpuser/scripts/script.sh"
CRON_SCHEDULE="* * * * *"         # Every 1 minute (changed from */5)
TEMP_FILE=$(mktemp) || exit 1     # Secure temp file

# Check if job exists
crontab -u "$CRON_USER" -l > "$TEMP_FILE" 2>/dev/null

if grep -q -F "$SCRIPT_PATH" "$TEMP_FILE"; then
    echo "Cron job already exists."
    rm "$TEMP_FILE"
    exit 0
fi

# Add new job
echo "$CRON_SCHEDULE $SCRIPT_PATH" >> "$TEMP_FILE"

if crontab -u "$CRON_USER" "$TEMP_FILE"; then
    echo "Cron job added successfully (runs every minute)."
else
    echo "Error: Failed to update crontab!" >&2
    rm "$TEMP_FILE"
    exit 1
fi

rm "$TEMP_FILE"

