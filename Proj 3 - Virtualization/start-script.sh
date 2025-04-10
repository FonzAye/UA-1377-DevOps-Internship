#!/bin/bash

SSH_KEY_DIRECTORY="./keys"
# Check if the keys/ directory exist
if [ ! -d $SSH_KEY_DIRECTORY ]; then
	echo "SSH key directory does not exist, creatung ..."
	mkdir $SSH_KEY_DIRECTORY
else
	echo "Directory already exists"
fi

SSH_KEY_PRIVATE="./keys/sftp_key"
SSH_KEY_PUBLIC="./keys/sftp_key.pub"
# Check if SSH keys are in keys/ directory
if [ ! -f $SSH_KEY_PRIVATE ] && [ ! -f $SSH_KEY_PUBLIC ]; then
	echo "Private and Public keys do not exist, creating ..."
	ssh-keygen -t ed25519 -f $SSH_KEY_PRIVATE -N "" -q
	echo "SSH key generated in keys/ directory"
else
	echo "Private and Public keys already created"
fi

# Starting VMs with Vagrant
vagrant up
