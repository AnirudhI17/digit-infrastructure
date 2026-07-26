# egov-common-masters Service Integration

This service manages organizational master data objects (e.g. departments, designations) across the DIGIT ecosystem.

---

## 1. Technical Analysis & Requirements

### System Specifications
*   **Build System**: Maven (Java)
*   **Java Runtime Version**: OpenJDK 11
*   **Application Port**: Internally `8080`, externally mapped to `8093`
*   **Database Requirements**: PostgreSQL. Utilizes connection pooling via HikariCP. Database name: `egov_common_masters`.
*   **Kafka Requirements**: Optional/Standard event bus connection configurations.
*   **External Service Dependencies**: Connects to `egov-mdms-service` for fetching structured JSON definitions.
*   **Shared Storage Requirements**: 
    - Mounts `./shared/config` to `/config:ro` for reading application parameters.
    - Mounts `./shared/storage` to `/data` for saving transient assets or files.

### Configuration Properties
*   `SPRING_DATASOURCE_URL`: PostgreSQL JDBC connection link.
*   `SPRING_DATASOURCE_USERNAME`: DB username.
*   `SPRING_DATASOURCE_PASSWORD`: DB password.
*   `KAFKA_BOOTSTRAP_SERVERS`: Kafka cluster host.

---

## 2. Docker & Execution Workflow

### Build Image
To build the service image locally using the zero-source container layout:
```bash
docker compose -f docker-compose.services.yml build egov-common-masters
```

### Run Stack
Start the core infrastructure and `egov-common-masters`:
```bash
docker compose \
  -f docker-compose.infrastructure.yml \
  -f docker-compose.services.yml up -d postgres egov-common-masters
```

### Health Verification (Smoke Test)
Once the service is active, verify that the health API route is responsive:
```bash
curl -f http://localhost:8093/egov-common-masters/health
```
A successful query should return HTTP 200 with status info.
