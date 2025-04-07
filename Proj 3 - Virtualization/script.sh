#!/bin/bash

# Define variables
REMOTE_SERVER=""
SSH_USER="sftpuser"
SSH_KEY="/home/sftpuser/.ssh/sftp_key"
REMOTE_FILE="/home/sftpuser/upload/entry-file.txt"

# Get current hostname
LOCAL_HOSTNAME=$(hostname)

# Get current date and time in the specified format
CURRENT_DATETIME=$(date "+%Y-%m-%d %H:%M:%S")

# Create the line to append
LINE_TO_APPEND="$CURRENT_DATETIME $LOCAL_HOSTNAME"

# Check if the SSH key exists
if [ ! -f "$SSH_KEY" ]; then
    echo "Error: SSH key not found at $SSH_KEY"
    exit 1
fi

# Check if the SSH key has the correct permissions
KEY_PERMISSIONS=$(stat -c "%a" "$SSH_KEY")
if [ "$KEY_PERMISSIONS" != "600" ]; then
    echo "Warning: SSH key has incorrect permissions: $KEY_PERMISSIONS"
    echo "Recommended: chmod 600 $SSH_KEY"
fi

# Connect to nodes and add to a file of create it first then add to it
node_id="$NODE_ID"
node_first="$NODE_FIRST"
node_last="$NODE_LAST"
KNOWN_HOSTS_FILE_PATH="$HOME/.ssh/known_hosts"

for i in $(seq "$node_first" "$node_last"); do
	if [ $i != $node_id ]; then
		REMOTE_SERVER="192.168.56.$((10 + i))"
		if grep -q "$REMOTE_SERVER" "$KNOWN_HOSTS_FILE_PATH"; then
			echo "$REMOTE_SERVER is in known_hosts, starting the SSH connection..."
		else
			echo "$REMOTE_SERVER is NOT in known_hosts, adding..."
			ssh-keyscan "$REMOTE_SERVER" >> "$KNOWN_HOSTS_FILE_PATH"
			if [ $? -eq 0 ]; then
				echo "Success: added $REMOTE_SERVER to known_hosts"
			else
				echo "Error: Failed to add $REMOTE_SERVER to known_hosts"
			fi
		fi
		ssh -i "$SSH_KEY" -o ConnectTimeout=10 -o BatchMode=yes "$SSH_USER@$REMOTE_SERVER" \
			"echo '$LINE_TO_APPEND' >> '$REMOTE_FILE'"
		if [ $? -eq 0 ]; then
			echo "Success: Line appended to $REMOTE_FILE on $REMOTE_SERVER"
			echo "Added: $LINE_TO_APPEND"
		else
			echo "Error: Failed to connect to the remote server or append the line"
			echo "Please check your connection settings and try again"
		fi
	fi
done	       

# Check the exit status of the SSH command
if [ $? -eq 0 ]; then
    echo "Success: Line appended to $REMOTE_FILE on $REMOTE_SERVER"
    echo "Added: $LINE_TO_APPEND"
    exit 0
else
    echo "Error: Failed to connect to the remote server or append the line"
    echo "Please check your connection settings and try again"
    exit 1
fi
