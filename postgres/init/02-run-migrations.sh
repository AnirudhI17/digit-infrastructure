#!/bin/bash
set -e

# ==============================================================================
# Dynamic PostgreSQL Migration & Seed Framework
# ==============================================================================
# Discovers migration folders and seed scripts, creates necessary databases, 
# and executes schema and seed SQL scripts in alphabetical order.

MIGRATIONS_DIR="/migrations"
SEED_DIR="/seed"

echo "=============================================================================="
echo "Starting Dynamic Schema Migration & Seed Framework..."
echo "=============================================================================="

# ------------------------------------------------------------------------------
# 1. RUN MIGRATIONS
# ------------------------------------------------------------------------------
if [ -d "$MIGRATIONS_DIR" ]; then
    echo "Scanning migrations in $MIGRATIONS_DIR..."
    
    # Sort folders alphabetically
    for dir in $(find "$MIGRATIONS_DIR" -mindepth 1 -maxdepth 1 -type d | sort); do
        SERVICE_NAME=$(basename "$dir")
        # Format database name by replacing hyphens with underscores
        DB_NAME=$(echo "$SERVICE_NAME" | tr '-' '_')
        
        echo "Processing migrations for service: $SERVICE_NAME (Database: $DB_NAME)..."
        
        # Ensure target database exists
        DB_EXISTS=$(psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "postgres" -tAc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'")
        if [ "$DB_EXISTS" != '1' ]; then
            echo "  Database '$DB_NAME' does not exist. Provisioning database..."
            psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "postgres" <<-EOSQL
                CREATE DATABASE "$DB_NAME";
                GRANT ALL PRIVILEGES ON DATABASE "$DB_NAME" TO "$POSTGRES_USER";
EOSQL
        fi
        
        # Find and sort SQL files alphabetically
        SQL_FILES=$(find "$dir" -maxdepth 1 -name "*.sql" -type f | sort)
        if [ -n "$SQL_FILES" ]; then
            for sql_file in $SQL_FILES; do
                echo "  -> Executing: $(basename "$sql_file")"
                psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$DB_NAME" -f "$sql_file"
            done
        else
            echo "  No SQL migration files found in '$SERVICE_NAME' folder."
        fi
    done
else
    echo "No migrations folder found at $MIGRATIONS_DIR."
fi

# ------------------------------------------------------------------------------
# 2. RUN SEED DATA
# ------------------------------------------------------------------------------
if [ -d "$SEED_DIR" ]; then
    echo "Scanning seed data in $SEED_DIR..."
    
    # Sort folders alphabetically
    for dir in $(find "$SEED_DIR" -mindepth 1 -maxdepth 1 -type d | sort); do
        SERVICE_NAME=$(basename "$dir")
        DB_NAME=$(echo "$SERVICE_NAME" | tr '-' '_')
        
        echo "Processing seed data for service: $SERVICE_NAME (Database: $DB_NAME)..."
        
        # Verify target database exists before seeding
        DB_EXISTS=$(psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "postgres" -tAc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'")
        if [ "$DB_EXISTS" = '1' ]; then
            SQL_FILES=$(find "$dir" -maxdepth 1 -name "*.sql" -type f | sort)
            if [ -n "$SQL_FILES" ]; then
                for sql_file in $SQL_FILES; do
                    echo "  -> Seeding: $(basename "$sql_file")"
                    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$DB_NAME" -f "$sql_file"
                done
            else
                echo "  No SQL seed files found in '$SERVICE_NAME' folder."
            fi
        else
            echo "  [Warning] Skipping seed: Database '$DB_NAME' does not exist."
        fi
    done
else
    echo "No seed folder found at $SEED_DIR."
fi

echo "=============================================================================="
echo "Migration & Seed Execution Complete!"
echo "=============================================================================="
