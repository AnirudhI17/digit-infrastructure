# Service Integration Requirements

This page documents the requirements and submissions teammates must satisfy before merging their microservice.

## Checklist for Service Submission

Before submitting your service to the cluster integration branch, you must supply the following files/information:

1.  **Dockerfile**: Must be a multi-stage, secure build running under a non-root user.
2.  **README.md**: Standard documentation detailing the service's purpose, API routes, and troubleshooting notes.
3.  **Environment Configuration**: Explicitly detail all required environment parameters in an `.env.example` in the microservice repository.
4.  **Health Check Endpoint**: Provide a standard HTTP health route (e.g. `/health` or `/status`) that returns HTTP 200 when the service is healthy.
5.  **Migration Scripts**: DDL/DML scripts placed in `postgres/migrations/<ServiceName>/` in this repo.
6.  **Kafka Topics**: Append any required topics to [`shared/config/kafka/topics.txt`](file:///f:/digit%20infrastructure/shared/config/kafka/topics.txt).
7.  **Elasticsearch Mappings**: Put mapping schemas in `shared/config/elasticsearch/mappings/<ServiceName>.json`.
8.  **Port Allocation**: Coordinate with the team to reserve a unique port range to avoid overlapping bindings.
9.  **Storage Manifest**: Submit a completed storage manifest YAML file (see template below).

---

## Storage Manifest Submission

You must submit a completed manifest file describing your container bounds.
Template file: [`shared/templates/storage-manifest-template.yaml`](file:///f:/digit%20infrastructure/shared/templates/storage-manifest-template.yaml)

```yaml
service:
  name: "egov-my-service"
  port: 8085
  health_endpoint: "/health"
storage:
  read:
    - "/data/uploads"
  write:
    - "/data/temp"
config:
  - "/config/application/egov-my-service.yml"
volumes:
  - host_path: "./shared/storage"
    container_path: "/data"
    read_only: false
  - host_path: "./shared/config"
    container_path: "/config"
    read_only: true
environment:
  - name: "MY_VARIABLE"
    value: "value"
dependencies:
  - "postgres"
```
Place this completed file at `docs/manifests/<service-name>.yaml` within your service repository for integration review.
