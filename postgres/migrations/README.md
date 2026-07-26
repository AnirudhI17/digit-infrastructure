# PostgreSQL Schema Migration & Seed Framework

This folder provides a zero-config, dynamic migration and seeding pipeline that automatically executes when the PostgreSQL database container is first spun up.

## How It Works

1. **Auto-Discovery**: On startup, the initialization container script searches all subdirectories inside `postgres/migrations/`.
2. **Database Provisioning**: The subdirectory name is converted into the target database name by replacing hyphens with underscores. For example:
   * Directory `egov-user/` will provision a database named `egov_user`.
   * Directory `egov-mdms-service/` will provision a database named `egov_mdms_service`.
3. **Migration Execution**: Within each subfolder, all `.sql` files are sorted and run in **alphabetical order**.
4. **Seed Provisioning**: Following schema migrations, the script automatically scans `postgres/seed/` for matching service subdirectories and runs seed inserts.

---

## Guide: Adding a New Migration for a Microservice

To add migrations for a new or existing microservice, follow these steps:

### 1. Identify or Create the Service Folder
Create a subdirectory under `postgres/migrations/` matching your microservice name:
```bash
mkdir -p postgres/migrations/egov-new-service
```

### 2. Create Schema SQL Files
Place your SQL scripts inside this subdirectory. Use alphabetical prefix sequencing to ensure stable order:
* `V1__init_schema.sql`
* `V2__add_audit_columns.sql`

*Always verify your DDL scripts are idempotent or utilize `IF NOT EXISTS` guards.*

### 3. Add Optional Seed Data
If your service requires local dummy records (such as system parameter values or dummy users), add them inside a matching subdirectory under `postgres/seed/`:
```bash
mkdir -p postgres/seed/egov-new-service
# Create seed file
touch postgres/seed/egov-new-service/01_insert_default_records.sql
```

### 4. Apply Changes
Teardown and restart your environment to run migrations on a clean DB:
```bash
./scripts/reset.sh
./scripts/setup.sh
```
