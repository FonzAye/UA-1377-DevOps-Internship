#!/bin/bash

# Arguments passed from Vagrantfile
NODE_ID=$1
NODE_FIRST=$2
NODE_LAST=$3

# Exit immediately if a command fails
set -e

echo "Provisioning node ${NODE_ID}..."

# Function to check if a user exists
user_exists() {
    id "$1" &>/dev/null
    return $?
}

export DEBIAN_FRONTEND=noninteractive

# Update and install OpenSSH server and cron
apt-get update && apt-get install -y openssh-server cron

# Create the sftpuser if it doesn't exist
if ! user_exists "sftpuser"; then
    useradd -m -d /home/sftpuser -s /bin/bash sftpuser
else
    echo "User sftpuser already exists"
fi

# Set directory permissions
chown sftpuser:sftpuser /home/sftpuser
chmod 755 /home/sftpuser

# Create necessary directories if they don't exist
for dir in upload scripts; do
    if [ ! -d "/home/sftpuser/$dir" ]; then
        mkdir -p "/home/sftpuser/$dir"
        echo "Created /home/sftpuser/$dir"
    fi
    chown sftpuser:sftpuser "/home/sftpuser/$dir"
    chmod 755 "/home/sftpuser/$dir"
done

# Copy and configure scripts
if [ -f "/vagrant/scripts/script.sh" ] && [ -f "/vagrant/scripts/cron.sh" ]; then
    cp /vagrant/scripts/script.sh /home/sftpuser/scripts/script.sh
    cp /vagrant/scripts/cron.sh /home/sftpuser/scripts/cron.sh
    chmod +x /home/sftpuser/scripts/script.sh /home/sftpuser/scripts/cron.sh
else
    echo "Warning: script.sh or cron.sh not found in /vagrant/scripts"
fi

# Set up SSH key authentication
mkdir -p /home/sftpuser/.ssh
chown sftpuser:sftpuser /home/sftpuser/.ssh
chmod 700 /home/sftpuser/.ssh

# Add public key
if [ -f "/vagrant/keys/sftp_key.pub" ]; then
    cat /vagrant/keys/sftp_key.pub >> /home/sftpuser/.ssh/authorized_keys
    chown sftpuser:sftpuser /home/sftpuser/.ssh/authorized_keys
    chmod 600 /home/sftpuser/.ssh/authorized_keys
else
    echo "Warning: /vagrant/keys/sftp_key.pub not found"
fi

# Copy private key (optional)
if [ -f "/vagrant/keys/sftp_key" ]; then
    cp /vagrant/keys/sftp_key /home/sftpuser/.ssh/sftp_key
    chown sftpuser:sftpuser /home/sftpuser/.ssh/sftp_key
    chmod 600 /home/sftpuser/.ssh/sftp_key
fi

# SSHD Configuration
SSHD_CONFIG="/etc/ssh/sshd_config"

if [ ! -f "${SSHD_CONFIG}.bak" ]; then
    cp "${SSHD_CONFIG}" "${SSHD_CONFIG}.bak"
fi

# Append configuration if not already present
if ! grep -q "Match User sftpuser" "${SSHD_CONFIG}"; then
    cat <<EOF >> "${SSHD_CONFIG}"

# SFTP Configuration for sftpuser
Match User sftpuser
    PasswordAuthentication no
    PermitTTY yes
    AllowTcpForwarding yes
EOF
    echo "Updated sshd_config with Match User block."
else
    echo "sshd_config already has SFTP block."
fi

# Restart SSH to apply changes
systemctl restart ssh
echo "SSH service restarted."

# Start cron job if present
if [ -x /home/sftpuser/scripts/cron.sh ]; then
    /home/sftpuser/scripts/cron.sh
    echo "Started cron script."
fi

echo "Provisioning for node ${NODE_ID} complete."

