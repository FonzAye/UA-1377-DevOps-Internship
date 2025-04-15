# SFTP Server Monitoring System

## Project Overview

This project implements an automated SFTP server monitoring system using Vagrant-provisioned virtual machines with a Python-based monitoring application. The system consists of three virtual machines running SFTP servers that periodically exchange timestamped files with each other. A Flask web application collects and visualizes the SFTP activity logs.

The architecture includes:
- Three Vagrant-managed VMs, each running a secure SFTP server
- SSH key-based authentication for secure access
- Scheduled Bash scripts for automated file transfers between servers
- A Python application that analyzes SFTP logs and generates reports
- A containerized Flask web interface for monitoring system activity

## Features

### Virtual Machine Infrastructure
- Three identical VMs provisioned through Vagrant
- SFTP servers configured on each VM with SSH key authentication
- Security hardening with `rkhunter` auditing tool

### Automated File Exchange
- Bash script runs every 5 minutes via cron scheduler
- Creates timestamped files on neighboring SFTP servers
- Each file contains metadata including date, time, and originating server name

### Monitoring and Reporting
- Python application parses SFTP logs across all servers
- Tracks file creation activities by machine and IP address
- Generates comprehensive activity summary reports
- Provides visualizations of server activity

### Containerized Web Interface
- Flask web application for viewing reports and statistics
- Custom lightweight Docker image for efficient deployment
- Multi-container setup orchestrated via docker-compose

## Installation Requirements

- Vagrant
- VirtualBox
- Docker and Docker Compose
- Python 3.8+

## Quick Start

1. Clone the repository:
```bash
git clone https://github.com/yourusername/sftp-monitoring-system.git
cd sftp-monitoring-system
```

2. Start the virtual machines:
```bash
chmod +x start-script.sh
./start-script.sh
```

3. Deploy the monitoring application:
```bash
cd python
docker build -t python-image .
docker-compose up -d
```

4. Access the web interface at `http://127.0.0.1:5000/`

## File Structure

```
.
├── python/                       # Python monitoring application
│   ├── app.py                    # Flask web application
│   ├── docker-compose.yml        # Docker Compose configuration
│   ├── Dockerfile                # Custom Docker image definition
│   ├── log_collector.py          # SFTP log parsing module
│   ├── requirements.txt          # Python dependencies
│   └── templates/                # Flask HTML templates
│       ├── charts.html           # Visualization templates
│       └── index.html            # Main dashboard template
├── README.md                     # Project documentation
├── scripts/                      # Automation scripts
│   ├── cron.sh                   # Cron job setup
│   ├── provision_sftp.sh         # SFTP server provisioning
│   └── script.sh                 # File transfer script
├── start-script.sh               # Main startup script
└── Vagrantfile                   # VM configuration
```

## Detailed Component Documentation

### Vagrant Configuration

The `Vagrantfile` defines three identical virtual machines, each configured with:
- Ubuntu 20.04 LTS
- Private network IP addressing
- Port forwarding for SFTP access
- Shared folders for log access

### SFTP Server Setup

The `provision_sftp.sh` script configures each VM with:
- OpenSSH server with SFTP subsystem
- SSH key-based authentication
- Directory structure for file exchange
- Security auditing with rkhunter

### Automated File Transfer

The `script.sh` Bash script:
- Generates timestamped files with server metadata
- Transfers files to neighboring SFTP servers
- Logs all transfer activities
- Runs every 5 minutes via cron (configured in `cron.sh`)

### Python Monitoring Application

The Python application consists of:
- `log_collector.py`: Parses SFTP logs and generates activity reports
- `app.py`: Flask web application for displaying reports and visualizations
- HTML templates for the web interface

### Docker Deployment

The application is containerized using:
- Custom lightweight Docker image based on Python Alpine
- Docker Compose for orchestrating the application container
- Volume mounting for persistent storage of logs and reports

## Contributing

Contributions to this project are welcome. Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/your-feature`)
5. Create a new Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
