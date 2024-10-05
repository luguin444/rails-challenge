#!/bin/bash

export PGPASSWORD="$POSTGRES_PASSWORD"

# Wait for PostgreSQL to be ready
until psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c '\q'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

# Create test database if it doesn't exist
psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -c "CREATE DATABASE test_products_api;"

# Run migrations and seeds
bundle exec rake db:migrate
bundle exec rake db:seed

# Execute the main process
exec "$@"
