#!/usr/bin/env python3
"""
SFTP Log Collector Script

Downloads log files from multiple Linux VMs using SFTP.
"""

import os
import sys
import logging
import paramiko

# Configure logging
logging.basicConfig(
    filename='error.log',
    level=logging.ERROR,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

def collect_logs(num_vms):
    """
    Collect log files from a range of VMs via SFTP.
    
    Args:
        num_vms: Number of VMs to connect to (from 192.168.56.11 to 192.168.56.1n)
    """
    # Create directory for collected logs if it doesn't exist
    os.makedirs("collected_logs", exist_ok=True)
    
    # Path to SSH private key
    private_key_path = os.path.expanduser(".key")
    if not os.path.exists(private_key_path):
        logging.error(f"SSH private key not found at {private_key_path}")
        print(f"Error: SSH private key not found at {private_key_path}")
        return
    
    # SFTP connection parameters
    username = "sftpuser"
    remote_file_path = "/home/sftpuser/upload/entry-file.txt"
    
    # Connect to each VM and download the log file
    for i in range(11, 11 + num_vms):
        ip_address = f"192.168.56.{i}"
        local_filename = f"collected_logs/entry-file_{ip_address}.txt"
        
        print(f"Connecting to {ip_address}...")
        
        try:
            # Create SSH client
            ssh = paramiko.SSHClient()
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            
            # Connect using private key
            try:
                pkey = paramiko.RSAKey.from_private_key_file(private_key_path)
            except paramiko.ssh_exception.PasswordRequiredException:
                logging.error(f"Private key is password protected. Unable to authenticate with {ip_address}")
                print(f"Error: Private key is password protected. See error.log for details.")
                continue
                
            # Connect to the server
            try:
                ssh.connect(
                    hostname=ip_address,
                    username=username,
                    pkey=pkey,
                    timeout=10
                )
            except Exception as e:
                logging.error(f"Failed to connect to {ip_address}: {str(e)}")
                print(f"Error connecting to {ip_address}. See error.log for details.")
                continue
            
            # Open SFTP session
            sftp = ssh.open_sftp()
            
            # Download the file
            try:
                sftp.get(remote_file_path, local_filename)
                print(f"Successfully downloaded log from {ip_address}")
            except Exception as e:
                logging.error(f"Failed to download file from {ip_address}: {str(e)}")
                print(f"Error downloading file from {ip_address}. See error.log for details.")
            
            # Close connections
            sftp.close()
            ssh.close()
            
        except Exception as e:
            logging.error(f"Unexpected error with {ip_address}: {str(e)}")
            print(f"Unexpected error with {ip_address}. See error.log for details.")

def main():
    collect_logs(num_vms)

if __name__ == "__main__":
    main()
