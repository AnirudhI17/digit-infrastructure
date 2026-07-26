#!/bin/bash
set -e

# ==============================================================================
# Multi-Database Bootstrap Script
# ==============================================================================
# This script initializes the primary database and any additional databases 
# specified in the POSTGRES_ADDITIONAL_DATABASES environment variable.

function create_user_and_database() {
    local db=$1
    echo "  Creating database '$db'..."
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
        CREATE DATABASE "$db";
        GRANT ALL PRIVILEGES ON DATABASE "$db" TO "$POSTGRES_USER";
EOSQL
}

if [ -n "$POSTGRES_ADDITIONAL_DATABASES" ]; then
    echo "Multiple database initialization requested: $POSTGRES_ADDITIONAL_DATABASES"
    for db in $(echo "$POSTGRES_ADDITIONAL_DATABASES" | tr ',' ' '); do
        # Check if database already exists
        DB_EXISTS=$(psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -tAc "SELECT 1 FROM pg_database WHERE datname='$db'")
        if [ "$DB_EXISTS" != '1' ]; then
            create_user_and_database "$db"
        else
            echo "  Database '$db' already exists. Skipping creation."
        fi
    done
    echo "Multiple databases initialization complete."
fi
