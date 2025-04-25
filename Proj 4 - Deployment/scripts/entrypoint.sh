#!/bin/sh

# Wait for PostgreSQL to be ready (timeout after 30 seconds)
timeout=30
while ! pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER"; do
  echo "Waiting for PostgreSQL to be ready..."
  sleep 1
  timeout=$((timeout - 1))
  if [ $timeout -eq 0 ]; then
    echo "Timeout: PostgreSQL not ready after 30 seconds."
    exit 1
  fi
done

# Run restore script
/scripts/pgsql_restore.sh /backup/2024-08-19.dump

# Start main application
exec "$@"
