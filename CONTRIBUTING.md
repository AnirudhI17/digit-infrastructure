# Developer Contribution Guidelines

This document outlines the workflow and architectural guidelines for developers contributing to the DIGIT microservices ecosystem. It ensures all services remain compatible with the shared infrastructure environment.

---

## 1. How to Run & Test Infrastructure Locally

To manage your local infrastructure components, use the pre-built utility scripts located in the `scripts/` directory:

### Validate Prerequisites
Before starting, check if your system meets the requirements:
```bash
./scripts/validate.sh
```

### Start the Infrastructure
Use the setup script to initialize environment variables, prepare storage folders, spin up Docker containers, and provision base messaging queues:
```bash
./scripts/setup.sh
```

### Monitor Container Status
Check if all database and streaming services are responsive and healthy:
```bash
./scripts/healthcheck.sh
```

### Backup & Restore Databases
*   **Backup**: `./scripts/backup-db.sh [database_name]`
*   **Restore**: `./scripts/restore-db.sh <path_to_backup_file> [target_database_name]`

### Clean & Reset Environment
To stop containers, delete volumes, and wipe all local databases and log caches:
```bash
./scripts/reset.sh
```

---

## 2. How to Add a New Microservice

When developing a new DIGIT microservice, **do not** add its application code or its unique Dockerfile to this repository. Keep the microservice in its own separate repository.

To integrate it with the shared local infrastructure:
1.  **Allocate Ports**: Select a host port range that doesn't conflict with existing infrastructure or other services (see [Service Matrix](file:///f:/digit%20infrastructure/docs/services.md)).
2.  **Declare Dependencies**: If your service requires custom configuration parameters or database connections, declare them in the local service's environment configuration file, referencing the core infrastructure credentials in [`.env.example`](file:///f:/digit%20infrastructure/.env.example).
3.  **Attach to Network**: Ensure your microservice's local compose profile joins the external bridge network named `digit-network`:
    ```yaml
    networks:
      default:
        name: digit-network
        external: true
    ```

---

## 3. How to Add SQL Migrations & Seed Data

The database uses a dynamic auto-discovery migration pipeline on startup.

### File Locations
*   **Migrations**: Add schema files to `postgres/migrations/<your-service-name>/`
*   **Seed Data**: Add static seed inserts to `postgres/seed/<your-service-name>/`

### Rules & Formatting
1.  **Naming Convention**: Subdirectory names must match the service name. The pipeline will automatically create the database with hyphens converted to underscores (e.g., `egov-workflow` becomes database `egov_workflow`).
2.  **Execution Ordering**: Scripts are executed alphabetically. Prefix your SQL scripts with an ordered sequential label (e.g., `V1__init.sql`, `V2__add_index.sql`).
3.  **Idempotency**: All SQL files **must** be idempotent. Use `CREATE TABLE IF NOT EXISTS` or check column presence before modifying tables.

---

## 4. How to Build & Run Microservice Docker Images

To keep local development smooth and fast:
*   **Multi-Stage Builds**: Always use multi-stage Dockerfiles to keep image sizes small (e.g., compile Java with Maven/Gradle in stage 1, copy binaries to a slim JRE Alpine image in stage 2).
*   **Non-Root User**: Run the container process under a non-privileged user (e.g., `USER node` or `USER base` depending on language runtimes).
*   **Building Locally**:
    ```bash
    docker build -t egov/your-microservice-name:latest .
    ```

---

## 5. How to Manage Kafka Topics

If your microservice publishes or consumes from a new event topic:
1.  Open the topic provisioning script: [`kafka/scripts/create-topics.sh`](file:///f:/digit%20infrastructure/kafka/scripts/create-topics.sh).
2.  Append your topic string to the `TOPICS` array variable.
3.  Ensure the configuration uses the environment variables `KAFKA_NUM_PARTITIONS` (default: 3) and `KAFKA_DEFAULT_REPLICATION_FACTOR` (default: 1) for local parity.

*Note: In development, `auto.create.topics.enable=true` is active, but explicitly declaring topics in the provisioning script ensures predictability.*

---

## 6. How to Add Elasticsearch Mappings

To index service schemas inside Elasticsearch:
*   Do not write schema configs directly to the container runtime. Instead, write index templates or configuration mappings as JSON files.
*   Store these schemas in a new folder at `elasticsearch/mappings/<service-name>.json` so that deployment pipelines can load them on staging/production initialization.
*   Apply mappings locally using simple CURL execution instructions:
    ```bash
    curl -X PUT "http://localhost:9200/your-index-name" -H 'Content-Type: application/json' -d @elasticsearch/mappings/your-service.json
    ```

---

## 7. Rules for Infrastructure Compatibility

To ensure compatibility with the shared developer environment, respect these rules:

1.  **Avoid `localhost` Inside Containers**: Do not hardcode `localhost` or `127.0.0.1` in your application connection strings. Use container service names instead (e.g., use `jdbc:postgresql://postgres:5432/egov_user` or `kafka:29092`).
2.  **External Port Configuration**: If you expose host ports, ensure they are parameterized using `.env` variables so teammates can shift ports if conflicts occur.
3.  **Resource Limits**: Limit the RAM/CPU usage of your service containers so developers can run all 15+ services concurrently. Use limits (e.g. `mem_limit: 512m`) in your microservice compose files.
4.  **Database Separation**: Do not write tables for different services in the same database. Ensure each service writes strictly to its designated database schema.
