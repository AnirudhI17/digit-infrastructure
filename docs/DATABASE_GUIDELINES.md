# Database Migration & Seeding Guidelines

This document details the guidelines for database management, schemas, indexes, and reference data seeding.

## Migration Structure

Every service must place its DDL and DML scripts under `postgres/migrations/<ServiceName>/`. 
Within this folder, separate scripts by stage:

```
postgres/migrations/<ServiceName>/
├── schema/
│   ├── V1__init_schema.sql
│   └── V2__add_indexes.sql
├── reference-data/
│   └── V1__load_core_types.sql
└── sample-data/
    └── V1__load_test_records.sql
```

## Folder Descriptions

1.  **`schema/`**:
    Contains all schema definition queries (e.g., `CREATE TABLE`, `ALTER TABLE`, indexes, foreign key constraints, primary keys). All scripts here must have idempotent guards (e.g. `CREATE TABLE IF NOT EXISTS` or checks).
2.  **`reference-data/`**:
    Core database records required for the service to function correctly in production (e.g., system roles, tenant definitions, config defaults).
3.  **`sample-data/`**:
    Local testing records used strictly for dev/test verification (e.g., test users, mock tickets, sample transactions).

## Rules & Conventions

*   **Prefix Ordering**: Files are executed alphabetically. Use numerical sequencing labels (e.g. `V1__init_user.sql`, `V2__add_indexes.sql`) to guarantee deterministic execution order.
*   **Zero Manual Actions**: Do not require developers to manually log in and run SQL statements via PGAdmin or `psql` shell. All migrations must be placed in the folders so they run automatically when Postgres bootstraps.
*   **DB Separation**: Every service must have its own subdirectory under `migrations/`. Do not run migrations of one service inside another service's database. The bootstrap framework converts service folder hyphens to database underscores dynamically.
