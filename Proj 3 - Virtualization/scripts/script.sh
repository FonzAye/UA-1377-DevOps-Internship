#!/bin/bash

# Load environment variables (expects NODE_ID, NODE_FIRST, NODE_LAST)
source /opt/env-vars

# === Configuration ===
SSH_KEY="/home/sftpuser/.ssh/sftp_key"
REMOTE_FILE="/home/sftpuser/upload/entry-file.txt"
KNOWN_HOSTS_FILE_PATH="$HOME/.ssh/known_hosts"
SSH_USER="sftpuser"  # Use sftpuser explicitly
KEY_PERMS_EXPECTED="600"

# === Derived Variables ===
LOCAL_HOSTNAME=$(hostname)
CURRENT_DATETIME=$(date "+%Y-%m-%d %H:%M:%S")
LINE_TO_APPEND="$CURRENT_DATETIME $LOCAL_HOSTNAME"

# === Sanity Checks ===

# Ensure SSH key exists
if [ ! -f "$SSH_KEY" ]; then
    echo "Error: SSH key not found at $SSH_KEY"
    exit 1
fi

# Warn if SSH key has incorrect permissions
KEY_PERMISSIONS=$(stat -c "%a" "$SSH_KEY")
if [ "$KEY_PERMISSIONS" != "$KEY_PERMS_EXPECTED" ]; then
    echo "Warning: SSH key permissions are $KEY_PERMISSIONS (expected $KEY_PERMS_EXPECTED)"
    echo "Recommended fix: chmod 600 $SSH_KEY"
fi

# === Loop through other nodes and append line remotely ===

for i in $(seq "$NODE_FIRST" "$NODE_LAST"); do
    if [ "$i" -ne "$NODE_ID" ]; then
        REMOTE_SERVER="192.168.56.$((10 + i))"

        # Ensure the server's key is in known_hosts
        if grep -q "$REMOTE_SERVER" "$KNOWN_HOSTS_FILE_PATH" 2>/dev/null; then
            echo "$REMOTE_SERVER is already in known_hosts"
        else
            echo "$REMOTE_SERVER is NOT in known_hosts, adding..."
            ssh-keyscan "$REMOTE_SERVER" >> "$KNOWN_HOSTS_FILE_PATH" 2>/dev/null
            if [ $? -eq 0 ]; then
                echo "Added $REMOTE_SERVER to known_hosts"
            else
                echo "Failed to scan or add $REMOTE_SERVER to known_hosts"
                continue
            fi
        fi

        # Try to append line on the remote host
        ssh -i "$SSH_KEY" -o ConnectTimeout=10 -o BatchMode=yes "$SSH_USER@$REMOTE_SERVER" \
		"echo '$LINE_TO_APPEND' >> '$REMOTE_FILE'"

        if [ $? -eq 0 ]; then
            echo "Success: Line appended to $REMOTE_FILE on $REMOTE_SERVER"
            echo "            └─ $LINE_TO_APPEND"
        else
            echo "Error: Failed to connect to $REMOTE_SERVER or append the line $LINE_TO_APPEND"
        fi
    fi
done

exit 0

