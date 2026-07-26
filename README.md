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
*   [`shared/`](file:///f:/digit%20infrastructure/shared/): Storage mount mappings, application configs, templates, examples, and logging folders shared across all microservices.
*   [`docs/`](file:///f:/digit%20infrastructure/docs/): Central documentation folder containing development guidelines.

## Development & Integration Guidelines

Teammates must read and strictly adhere to the following developer guidelines when writing and integrating microservices:

*   [**Local Developer Setup Guide**](file:///f:/digit%20infrastructure/docs/DEVELOPER_SETUP.md): Step-by-step local clone-to-launch guide and service logging setup.
*   [**Platform Architecture Overview**](file:///f:/digit%20infrastructure/docs/ARCHITECTURE.md): Structural layout showing container port bounds and topology.
*   [**Storage Integration Guidelines**](file:///f:/digit%20infrastructure/docs/STORAGE_GUIDELINES.md): Mount mappings conventions for writing files strictly to `/data/`.
*   [**Configuration Management Guidelines**](file:///f:/digit%20infrastructure/docs/CONFIGURATION_GUIDELINES.md): Standard read conventions from `/config/` directories inside containers.
*   [**Database Migration & Seeding Guidelines**](file:///f:/digit%20infrastructure/docs/DATABASE_GUIDELINES.md): SQL script directory definitions and ordering conventions.
*   [**Service Integration Requirements**](file:///f:/digit%20infrastructure/docs/SERVICE_INTEGRATION_REQUIREMENTS.md): Service submission requirements, manifests, port allocations, and healthchecks.

## Quick Start

### 1. Prerequisites
Ensure your local development machine satisfies the minimum resource configurations (e.g., 16GB RAM recommended, Docker, Docker Compose, Bash/WSL/Git Bash).

### 2. Verify Your Environment
Before spinning up any services, validate that your local environment is ready:
```bash
./scripts/validate.sh
```

### 3. Setup and Launch Environment
Bootstraps local folder directory mounts, generates environment variables, and launches the entire container stack:
```bash
./scripts/setup.sh
```

### 4. Verify Services Status
Verify that all running infrastructure engines are healthy and responsive:
```bash
./scripts/healthcheck.sh
```

---
For detailed service mapping, port allocations, and architecture details, refer to the [`docs/`](file:///f:/digit%20infrastructure/docs/) folder.
