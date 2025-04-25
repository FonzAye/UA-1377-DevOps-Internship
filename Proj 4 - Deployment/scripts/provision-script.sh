set -e

echo "Provisioning ..."

# Function to check if a user exists
user_exists() {
    id "$1" &>/dev/null
    return $?
}

# Update and install 
apt-get update && apt-get install -y postgresql postgresql-contrib redis-server


# Checking the installation status of PostgreSQL and Redis
psql --version
redis-server --version
