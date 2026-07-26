# DIGIT Infrastructure

This repository provides the core, shared infrastructure services required by DIGIT (Digital Infrastructure for Governance, Impact & Transformation) microservices for local development and testing.

## Overview

Rather than maintaining separate, duplicated infrastructure setups across multiple microservice repositories, this repository serves as a single source of truth for standard developer dependency stacks. It configures and bootstraps the following central services:

- **PostgreSQL**: Relational database with automated multi-database bootstrap.
- **Apache Kafka & Zookeeper**: Event streaming broker and coordination engine.
- **Redis**: Fast, in-memory key-value store for caching and session state.
- **Elasticsearch**: Search and analytics engine.

All services are designed to be run via containerized configurations using local mounts for persistent volume storage.

## Repository Directory Structure

Below is an overview of the directory organization in this repository:

*   [`postgres/`](file:///f:/digit%20infrastructure/postgres/): Contains configuration files, DB initialization hooks, and folders for migrations and seeding.
*   [`kafka/`](file:///f:/digit%20infrastructure/kafka/): Houses broker and zookeeper configurations, and topic provisioning helper scripts.
*   [`redis/`](file:///f:/digit%20infrastructure/redis/): Standard configurations for caching and persistence limits.
*   [`elasticsearch/`](file:///f:/digit%20infrastructure/elasticsearch/): Node settings and resource boundaries optimized for local development.
*   [`scripts/`](file:///f:/digit%20infrastructure/scripts/): Operational scripts for system checks, environment bootstrapping, and health monitoring.
*   [`docs/`](file:///f:/digit%20infrastructure/docs/): Detailed documentation about port mapping, service dependencies, and troubleshooting guidelines.

## Quick Start

### 1. Prerequisites
Ensure your local development machine satisfies the minimum resource configurations (e.g., 16GB RAM recommended, Docker, Docker Compose, Bash/WSL/Git Bash).

### 2. Verify Your Environment
Before spinning up any services, validate that your local environment is ready:
```bash
./scripts/validate.sh
```

### 3. Bootstrap Environment Variables
Generate the `.env` configuration file from the provided example:
```bash
./scripts/bootstrap.sh
```
*(This creates local `.env` configuration and initializes required local folders for persistent data).*

### 4. Verify Services Status
Once the containers are running (to be orchestrated using docker compose configurations introduced in later phases), verify their operational status:
```bash
./scripts/healthcheck.sh
```

---
For detailed service mapping, port allocations, and architecture details, refer to the [`docs/`](file:///f:/digit%20infrastructure/docs/) folder.
