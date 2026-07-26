# DIGIT Local Dependency Environment

This repository provides a portable, zero-configuration, reproducible development environment containing all shared infrastructure and Java dependency services required to test the Go implementations of `tl-service` and `tl-calculator`.

---

## 1. Repository Directory Structure

```
digit-infrastructure/
├── docker-compose.infrastructure.yml  # Shared infrastructure services (DB, Queue, Search, Cache)
├── docker-compose.services.yml        # Java dependency services (egov-user, egov-workflow, etc.)
├── .env.example                       # Central environment variables template
├── README.md                          # Quickstart guide
├── CONTRIBUTING.md                    # Integration & coding guidelines
│
├── services/                          # Zero-source Docker builds for dependency services
│   ├── egov-user/                     # Each service contains:
│   │   ├── Dockerfile                 # Multi-stage Docker builder (clones from official DIGIT repo)
│   │   ├── .dockerignore              # Ignore rules
│   │   ├── .env.example               # Port defaults
│   │   ├── config/                    # Config overrides
│   │   └── README.md                  # Service description
│   ├── egov-mdms-service/
│   ├── pdf-service/
│   ├── ...
│
├── postgres/                          # SQL Migrations, reference data, and configs
├── kafka/                             # Broker and zookeeper properties
├── redis/                             # redis.conf default configurations
├── elasticsearch/                     # elasticsearch.yml parameters
├── shared/                            # Local mounts for /data and /config
├── scripts/                           # Operations (setup, health checks, backup, resets)
└── docs/                              # Detailed engineering guidelines
```

---

## 2. Quick Start Orchestration

Follow these steps to run the complete environment:

### Step 1: Pre-requisites Verification & Setup
First, verify your system meets memory specifications and prepare local directories:
```bash
./scripts/setup.sh
```
*(This automatically runs validations, boots up core environment variables, and pre-allocates directories).*

### Step 2: Build Application Service Images
Since the repository holds zero Java source files directly, service images are compiled by cloning module source files dynamically from the official DIGIT repository during the Docker build stage:
```bash
docker compose -f docker-compose.services.yml build
```

### Step 3: Run the Complete Dependency Stack
Start both the core infrastructure engines and all Java dependency services using the multi-file compose command:
```bash
docker compose \
  -f docker-compose.infrastructure.yml \
  -f docker-compose.services.yml up -d
```

### Step 4: Verify Environment Health
```bash
./scripts/healthcheck.sh
```

---

## 3. Team Integration Workflow

Teammates must follow this structured process to add or configure Java services:

1.  **Clone Official Java Service**: Work locally on the Java repository to test configurations.
2.  **Verify Service Locally**: Confirm the service starts and connects successfully.
3.  **Expose Configurations**: Decouple any hardcoded database URL links, passwords, and file paths.
4.  **Create Dockerfile**: Write a multi-stage Dockerfile that fetches source code from the official DIGIT-OSS repository and packages the target JAR.
5.  **Place Artifacts in Services Directory**: Save the `Dockerfile`, `.dockerignore`, and service README under `services/<service-name>/`. Do **not** commit Java source code or JAR files.
6.  **Add Service to Compose**: Register the service definition inside [`docker-compose.services.yml`](file:///f:/digit%20infrastructure/docker-compose.services.yml).
7.  **Commit & Push**: Push changes to this repository so colleagues can pull and run updates instantly.
