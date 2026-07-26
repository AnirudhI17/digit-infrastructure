#!/bin/bash
set -e

# ==============================================================================
# Dynamic PostgreSQL Migration & Seeding Engine
# ==============================================================================
# Discovers migration directories dynamically. For each service, it executes:
# 1. Schema definition files (tables, indexes, constraints)
# 2. Reference data (required configuration and system parameters)
# 3. Sample test data (local developer records)

MIGRATIONS_DIR="/migrations"

echo "=============================================================================="
echo "Starting Dynamic Schema Migration & Seeding Pipeline..."
echo "=============================================================================="

# Helper function to execute SQL files in a folder
execute_sql_files() {
    local folder_path=$1
    local db_name=$2
    local label=$3
    
    if [ -d "$folder_path" ]; then
        local sql_files=$(find "$folder_path" -maxdepth 1 -name "*.sql" -type f | sort)
        if [ -n "$sql_files" ]; then
            echo "  Running $label scripts..."
            for sql_file in $sql_files; do
                echo "    -> Executing: $(basename "$sql_file")"
                psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$db_name" -f "$sql_file"
            done
        fi
    fi
}

if [ -d "$MIGRATIONS_DIR" ]; then
    echo "Scanning service migrations in $MIGRATIONS_DIR..."
    
    # Sort service folders alphabetically
    for dir in $(find "$MIGRATIONS_DIR" -mindepth 1 -maxdepth 1 -type d | sort); do
        SERVICE_NAME=$(basename "$dir")
        DB_NAME=$(echo "$SERVICE_NAME" | tr '-' '_')
        
        echo "Processing databases and files for: $SERVICE_NAME (Database: $DB_NAME)..."
        
        # Ensure database exists
        DB_EXISTS=$(psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "postgres" -tAc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'")
        if [ "$DB_EXISTS" != '1' ]; then
            echo "  Database '$DB_NAME' does not exist. Provisioning database..."
            psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "postgres" <<-EOSQL
                CREATE DATABASE "$DB_NAME";
                GRANT ALL PRIVILEGES ON DATABASE "$DB_NAME" TO "$POSTGRES_USER";
EOSQL
        fi
        
        # Execute in order: Schema, Reference Data, Sample Data
        execute_sql_files "$dir/schema" "$DB_NAME" "Schema/DLL"
        execute_sql_files "$dir/reference-data" "$DB_NAME" "Reference Data"
        execute_sql_files "$dir/sample-data" "$DB_NAME" "Sample Test Data"
        
        # Backward compatibility: run SQL files directly in the root of service folder if any exist
        execute_sql_files "$dir" "$DB_NAME" "Legacy Root Migration"
    done
else
    echo "No migrations folder found at $MIGRATIONS_DIR."
fi

# Backward compatibility: execute seed scripts from /seed directory if it exists
SEED_DIR="/seed"
if [ -d "$SEED_DIR" ]; then
    echo "Scanning legacy seed data in $SEED_DIR..."
    for dir in $(find "$SEED_DIR" -mindepth 1 -maxdepth 1 -type d | sort); do
        SERVICE_NAME=$(basename "$dir")
        DB_NAME=$(echo "$SERVICE_NAME" | tr '-' '_')
        DB_EXISTS=$(psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "postgres" -tAc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'")
        if [ "$DB_EXISTS" = '1' ]; then
            execute_sql_files "$dir" "$DB_NAME" "Legacy Seed Data"
        fi
    done
fi

echo "=============================================================================="
echo "Migration & Seeding Pipeline Complete!"
echo "=============================================================================="
