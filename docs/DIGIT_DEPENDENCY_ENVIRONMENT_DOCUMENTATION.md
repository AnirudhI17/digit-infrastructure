# DIGIT Dependency Environment: Implementation Guide
### *Shared Developer Infrastructure and Collaboration Workflow*

---

> [!NOTE]
> This document serves as the **Single Source of Truth** for the development team. It governs the configuration, execution, testing, and contribution protocols required to construct a zero-config, reproducible dependency environment.

---

## 1. Project Background and Objective

Our team is tasked with migrating **only two** core services from Java to Go:
1.  [`tl-service`](file:///f:/infosys%20project/DIGIT-OSS/municipal-services/tl-calculator/src/main/java/org/egov/tlcalculator/config/TLCalculatorConfigs.java) (Trade License Service)
2.  [`tl-calculator`](file:///f:/infosys%20project/DIGIT-OSS/municipal-services/tl-calculator/src/main/java/org/egov/tlcalculator/config/TLCalculatorConfigs.java) (Trade License Calculator)

All other services in the DIGIT ecosystem **will remain in Java** and are not migration targets. Instead, they act as critical upstream dependencies that `tl-service` and `tl-calculator` require to function. 

These Java dependency services include:
*   `egov-user` (User authentication and profile management)
*   `egov-localization` (Localization and translation lookup)
*   `egov-mdms-service` (Master Data Management Service)
*   `egov-location` (Geographic and boundary services)
*   `egov-idgen` (ID Generation service)
*   `egov-persister` (Dynamic database ingestion pipeline)
*   `egov-workflow-v2` (Business logic state machine orchestration)
*   `egov-accesscontrol` (Access rules and permissions)
*   `pdf-service` (Dynamic certificate and bill layout generation)
*   `egov-enc-service` (Encryption and data security)

### The Problem

During collaborative development, running these dependencies on different workstations frequently fails due to:
*   **Hardcoded Paths**: References to `C:\Users\username\Desktop\configs` or `/home/user/Downloads/...`
*   **Volatile Variables**: Missing `.env` values or mismatched environment keys.
*   **Manual Databases Init**: Developers spending hours executing SQL commands manually on local DB clients.
*   **Host Mismatches**: Services expecting localhost ports, crashing when docker network configurations isolated them.

### The Objective

We are building a fully portable, zero-configuration local workspace. Any teammate should be able to run:
```bash
git clone <infrastructure-repo>
./scripts/setup.sh
```
and obtain a working relational database, message broker, caching layer, searching engine, and core configurations ready to serve the migrated services.

---

## 2. Infrastructure Platform Topology

The `digit-infrastructure` repository houses the Docker configurations, PostgreSQL migration scripts, Elasticsearch indexes, Kafka topic auto-provisioners, and Redis states that tie the platform together.

```mermaid
graph TD
    subgraph Host Workstation
        subgraph Developer Environment [Infrastructure Namespace]
            DB[(PostgreSQL)]
            Cache[(Redis)]
            ES[(Elasticsearch)]
            ZK[Zookeeper]
            KF[Kafka Broker]
        end

        subgraph Local Shared Directories
            Storage["shared/storage/ (Mounted: /data)"]
            Config["shared/config/ (Mounted: /config)"]
            Logs["shared/logs/ (Mounted: /var/log)"]
        end

        subgraph DIGIT Dependency Services [Java Runtime Space]
            SVC_USER[egov-user] --> DB
            SVC_USER --> Cache
            SVC_USER -.-> Storage
            SVC_USER -.-> Config
            
            SVC_WF[egov-workflow-v2] --> DB
            SVC_WF --> KF
            SVC_WF -.-> Config
            
            SVC_MDMS[egov-mdms-service] --> DB
            SVC_MDMS -.-> Config
        end

        subgraph Go Migration Targets [Go Runtime Space]
            GO_TL[Go tl-service] --> DB
            GO_TL --> KF
            GO_TL -.-> Config
            
            GO_CALC[Go tl-calculator] --> GO_TL
            GO_CALC --> DB
        end
    end

    KF <--> ZK
```

> [!IMPORTANT]
> The infrastructure repository is strictly an **internal development platform**. It is NOT part of the final Infosys submission. Only the Go source code repositories for `tl-service` and `tl-calculator` will be submitted.

---

## 3. Repository Directory Structure

The repository is structured to separate global infrastructure logic from runtime volumes and service configurations:

```
digit-infrastructure/
├── .env.example                       # Central environment overrides
├── .gitignore                         # Excludes data volumes, logs, and local env files
├── README.md                          # Quickstart guide
├── CONTRIBUTING.md                    # Developer code styles and integration policies
├── docker-compose.infrastructure.yml  # Shared infrastructure services stack
├── docs/                              # Detailed engineering guidelines
│   ├── ARCHITECTURE.md
│   ├── CONFIGURATION_GUIDELINES.md
│   ├── DATABASE_GUIDELINES.md
│   ├── DEVELOPER_SETUP.md
│   ├── SERVICE_INTEGRATION_REQUIREMENTS.md
│   └── STORAGE_GUIDELINES.md
├── postgres/                          # PostgreSQL config and init scripts
│   ├── config/                        # postgresql.conf and pg_hba.conf
│   ├── init/                          # DB initialization & migration runner
│   └── migrations/                    # Dynamic per-service migrations
│       ├── egov-user/
│       │   ├── schema/
│       │   ├── reference-data/
│       │   └── sample-data/
│       └── egov-mdms-service/
├── kafka/                             # Zookeeper and Broker properties
├── redis/                             # redis.conf default rules
├── elasticsearch/                     # elasticsearch.yml rules
├── scripts/                           # Operations (setup, health, backup, reset)
└── shared/                            # Mount points shared by container runtimes
    ├── config/                        # Mounted to /config:ro in containers
    │   ├── application/
    │   ├── mdms/
    │   ├── localization/
    │   ├── workflow/
    │   └── schemas/
    ├── storage/                       # Mounted to /data in containers
    │   ├── uploads/
    │   ├── filestore/
    │   ├── pdfs/
    │   ├── exports/
    │   └── temp/
    ├── templates/                     # Storage manifest templates
    └── logs/                          # Mounted by containers for debugging
```

---

## 4. Teammate Step-by-Step Workflow

Every developer assigned to configure a Java dependency service must follow this workflow to integrate it into the environment:

```mermaid
stateDiagram-v2
    [*] --> CloneInfra : 1. Clone Infrastructure Repo
    CloneInfra --> StartInfra : 2. Start Infra via scripts/setup.sh
    StartInfra --> CloneService : 3. Clone Assigned Java Service
    CloneService --> DecouplePaths : 4. Decouple Local Paths & Hardcoded Configs
    DecouplePaths --> AddConfigs : 5. Add Configs to shared/config/
    AddConfigs --> AddMigrations : 6. Add Migrations to postgres/migrations/
    AddMigrations --> AddSeed : 7. Add Seed Data (Ref & Test)
    AddSeed --> ConfigureVolumes : 8. Configure Volume Mounts
    ConfigureVolumes --> StartService : 9. Execute Service Container
    StartService --> SmokeTest : 10. Smoke Test Exposed REST Endpoints
    SmokeTest --> BuildDocker : 11. Build Portable Docker Image
    BuildDocker --> UpdateCompose : 12. Update docker-compose.infrastructure.yml
    UpdateCompose --> PushChanges : 13. Commit & Push Infrastructure Updates
    PushChanges --> [*]
```

### Detailed Workflow Steps

1.  **Clone Infrastructure Repository**:
    Download the central infrastructure coordinator repository:
    ```bash
    git clone https://github.com/AnirudhI17/digit-infrastructure.git
    ```
2.  **Start Infrastructure**:
    Prepare directories and boot up Core DB, Queues, Cache, and Search engines:
    ```bash
    ./scripts/setup.sh
    ```
3.  **Clone Assigned Java Service**:
    Clone the repository containing the source code of the Java service assigned to you.
4.  **Configure Service to Use Shared Infrastructure**:
    Change hostnames from `localhost` to service names matching the Docker Compose network (e.g., `jdbc:postgresql://postgres:5432/egov_user`).
5.  **Remove Machine-Specific Paths**:
    Scan the codebase for any absolute local paths. Replace them with standardized mount folder links (e.g. `/data/uploads`).
6.  **Remove Hardcoded Configuration**:
    Expose critical variables as parameter hooks (e.g. use `${SPRING_DATASOURCE_PASSWORD}` rather than writing plain credentials in files).
7.  **Include Missing Configuration Files**:
    Put required service property files in `shared/config/application/` so they are version-controlled.
8.  **Include Database Migrations**:
    Write schema definition files under `postgres/migrations/<ServiceName>/schema/`.
9.  **Include Seed Data**:
    If your service requires static defaults or developer dummy inputs, write SQL scripts under `postgres/migrations/<ServiceName>/reference-data/` and `postgres/migrations/<ServiceName>/sample-data/`.
10. **Configure Shared Volumes**:
    Map container folders to look up configurations at `/config` and store outputs at `/data`.
11. **Run Service**:
    Execute the service container locally within the `digit-network` Docker network.
12. **Smoke Test Every Endpoint**:
    Execute a curl command against each exposed API route to ensure the service runs and connects to its DB, Cache, and Queues.
13. **Build Docker Image**:
    Compile the service into a lightweight, portable Docker image.
14. **Update Infrastructure Repository**:
    Append your service's configuration, ports, volumes, and health tests to the infrastructure repository.
15. **Commit and Push Changes**:
    Push modifications to the central git repository so your team members can fetch and receive the configured dependencies automatically.

---

## 5. Development Standards: Prohibited vs. Required Practices

To guarantee absolute portability, we enforce the following development rules:

### Prohibited Practices (What Should NEVER Exist)

*   ❌ **Local User Folder Paths**: Never write code referencing `C:\Users\Name\Desktop\...` or `/Users/name/Downloads/...`.
*   ❌ **Manual SQL Execution**: Teammates must never be forced to run SQL statements using PGAdmin/DBeaver. All database tables and lookups must run automatically on startup.
*   ❌ **Hardcoded Connection Endpoints**: Never use `127.0.0.1` or `localhost` within container networks.
*   ❌ **Missing Properties Configurations**: Properties files must never be kept locally on a developer's machine. They must be checked in under `shared/config/`.
*   ❌ **Unparameterized Secrets**: Mapped database password variables must never be committed as plain text strings in source control. Use environment variable expansions.

### Required Practices (What Should ALWAYS Exist)

*   ✅ **Centralized Versioned Configs**: All service settings must live in `shared/config/` and mount as `/config`.
*   ✅ **Shared Data Mounts**: All file-writing procedures must write to directories under `/data/`.
*   ✅ **Deterministic Migration Stages**: All SQL scripts must follow the schema/reference/sample directory pattern:
    ```
    postgres/migrations/<ServiceName>/
    ```
*   ✅ **Idempotency**: Every SQL script must be safe to run multiple times (e.g. `CREATE TABLE IF NOT EXISTS`, `ALTER TABLE ... ADD COLUMN IF NOT EXISTS`).
*   ✅ **External Network Binding**: All custom containers must bind to the external `digit-network` bridge.

---

## 6. Service Integration Requirements Checklists

Before submiting a completed dependency service config, ensure it satisfies the checklist below:

| Requirement Area | Checklist | Verification Method |
| :--- | :--- | :--- |
| **Ports** | Port must be unallocated. | Check [docs/services.md](file:///f:/digit%20infrastructure/docs/services.md) |
| **Database** | Subfolder named after service exists in `postgres/migrations/`. | Verify folder structure. |
| **Migrations** | DDL schema creation contains indexes and foreign key constraints. | Runs via `postgres/init/02-run-migrations.sh`. |
| **Seed Data** | Both reference configurations and local sample test data exist. | Stored in `reference-data/` and `sample-data/`. |
| **Shared Storage** | Operations mapped strictly to `/data/`. | Check Storage Manifest YAML mapping. |
| **Shared Config** | Mapped property files reside in `shared/config/application/`. | Check file existence. |
| **Kafka Topics** | Appended to `shared/config/kafka/topics.txt`. | Run `./scripts/setup.sh` and list topics. |
| **ES Mappings** | Mapping JSON exists in `shared/config/elasticsearch/mappings/`. | Check Elasticsearch health API. |
| **Containerization**| Dockerfile uses multi-stage builds running as a non-root user. | Inspect Dockerfile structure. |
| **Health Check** | An active HTTP health endpoint (e.g., `/health`) is exposed. | `curl http://localhost:<port>/health` returns 200. |

---

## 7. Endpoint Verification (Smoke Testing)

Complete QA validation or functional testing is **not** required for the Java dependency services. We only require **Smoke Testing**.

### Goal of Smoke Testing
To prove that:
1.  The service compiles and starts.
2.  The service successfully connects to PostgreSQL, Redis, or Kafka.
3.  The configuration mappings at `/config` are resolved.

### Test Procedure
Verify that at least one primary REST endpoint (such as user search, location lookup, or local localization dictionary lookup) can be invoked once:
```bash
curl -X POST "http://localhost:8080/egov-user/users/_search" \
     -H "Content-Type: application/json" \
     -d '{"requestInfo":{},"tenantId":"pb"}'
```
If the command returns a valid JSON response without connection timeout errors, the service is verified.

---

## 8. Service Submission: Storage Manifest & Definition of Done

Teammates must create and submit a storage manifest template for each service they configure.

### Mapped Storage Manifest Template
File location: [`shared/templates/storage-manifest-template.yaml`](file:///f:/digit%20infrastructure/shared/templates/storage-manifest-template.yaml)

```yaml
service:
  name: "egov-service-name"
  port: 8080
  health_endpoint: "/health"
storage:
  read:
    - "/data/uploads"
  write:
    - "/data/temp"
config:
  - "/config/application/application.yml"
volumes:
  - host_path: "./shared/storage"
    container_path: "/data"
    read_only: false
  - host_path: "./shared/config"
    container_path: "/config"
    read_only: true
environment:
  - name: "SPRING_PROFILES_ACTIVE"
    value: "dev"
dependencies:
  - "postgres"
  - "kafka"
```

### Definition of Done (DoD)

A service is considered **Done** and ready for integration testing only if:
- [ ] The service Dockerfile compiles successfully on Linux, Windows, and macOS.
- [ ] The container starts without manual host directory mapping configuration.
- [ ] Properties and properties configurations are committed in `shared/config/application/`.
- [ ] Directory volumes are mapped to `/data` and `/config`.
- [ ] Database migrations are checked in under `postgres/migrations/<ServiceName>/schema/`.
- [ ] Reference data and sample data files are checked in.
- [ ] All exposed endpoints have been smoke tested.
- [ ] `docker-compose.infrastructure.yml` has been updated with the service container definition.
- [ ] Host service lists and port maps have been documented in the repository readme files.

---

## 9. Integration Flow and Final Deliverables

Once all teammates complete configuring their assigned dependency services:

1.  **Orchestrating the Environment**:
    The integration engineer clones the infrastructure repository and spins up the environment:
    ```bash
    git clone https://github.com/AnirudhI17/digit-infrastructure.git
    cd digit-infrastructure
    ./scripts/setup.sh
    ```
    This launches all database engines, message queues, caches, and the 10+ Java dependency services.
2.  **Connecting Go Migration Targets**:
    Configure the Go migration targets (`tl-service` and `tl-calculator`) to use the running infrastructure:
    ```bash
    # Run the migrated Go service pointing to our local Docker network dependencies
    export KAFKA_BOOTSTRAP_SERVERS="localhost:9092"
    export DB_URL="postgres://postgres:postgres@localhost:5432/egov_trade_license?sslmode=disable"
    go run main.go
    ```
3.  **Perform Integration Validation**:
    Run end-to-end user workflows (e.g. creating a trade license and calculating fees) using the Go services, verifying they store data in PostgreSQL and stream events to Kafka successfully.

### Final Submission Deliverables
The infrastructure repository is strictly for local orchestration and verification. The final project submission to Infosys consists **only** of:
*   The Go source code repository for `tl-service`.
*   The Go source code repository for `tl-calculator`.
