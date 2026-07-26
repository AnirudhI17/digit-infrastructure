# Developer Local Setup Guide

This page explains how to get the shared infrastructure environment up and running on your local development machine.

## Prerequisites
Ensure you have the following installed:
*   Docker & Docker Compose (v2)
*   Bash-compatible shell (Linux Terminal, macOS Terminal, WSL, or Git Bash on Windows)

---

## 1. Quick Start Launch

### Clone the Repository
```bash
git clone <infrastructure-repo-url>
cd digit-infrastructure
```

### Validate and Bootstrap
Execute the setup helper script. This validates your hardware, generates the local `.env` configuration file, creates local data storage mount folders with open permissions, and launches the container stack:
```bash
./scripts/setup.sh
```

*(This automatically configures database schemas, inserts reference seed data, creates Kafka topics, and loads Elasticsearch mappings).*

### Verify Services Health
```bash
./scripts/healthcheck.sh
```

---

## 2. Managing Service Logs & Host Mounting

By default, all containers write log files locally inside the container filesystem. To enable host log mounting for easy debugging on your local workstation:

1.  Create a directory inside `shared/logs/` for your service:
    ```bash
    mkdir -p shared/logs/my-service
    ```
2.  Mount the directory in your service's `docker-compose` definition:
    ```yaml
    services:
      my-service:
        image: egov/my-service:latest
        volumes:
          - ./shared/logs/my-service:/var/log/my-service
        environment:
          - LOG_PATH=/var/log/my-service/application.log
    ```
3.  Now, logs written by the container are readable on your host machine at `./shared/logs/my-service/application.log`.

---

## 3. Teardown & Reset
To wipe all running databases, message broker logs, search index stores, and local cache directories:
```bash
./scripts/reset.sh
```
