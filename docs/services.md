# Service Configuration Details

This reference page documents the default configurations, port assignments, and credentials for the shared development infrastructure services.

## Service Matrix

| Service | Container Port | Host Port | Default User | Default Credentials | Description / Purpose |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **PostgreSQL** | `5432` | `5432` | `postgres` | `postgres` | Primary relational data store. |
| **Zookeeper** | `2181` | `2181` | *N/A* | *None* | Configuration manager for Kafka. |
| **Kafka** | `9092` | `9092` | *N/A* | *None* | Shared event broker / transaction queue. |
| **Redis** | `6379` | `6379` | *N/A* | *None (Auth disabled on dev)* | Local caching, session, and tenant lookup store. |
| **Elasticsearch** | `9200` | `9200` | *N/A* | *None (Security disabled on dev)*| Log aggregation and search query index. |

---

## Detailed Component Configs

### 1. PostgreSQL
- **Default Database**: `digit_db`
- **Tuned Parameters**: `shared_buffers = 256MB`, `max_connections = 100`.
- **Preconfigured Databases (Dynamic)**:
  - `egov_user`
  - `egov_localization`
  - `egov_mdms`
  - `egov_filestore`
  - `egov_pg`

### 2. Apache Kafka & Zookeeper
- **Zookeeper Connection**: `zookeeper:2181`
- **Default Partitions**: `3`
- **Default Replication Factor**: `1` (tuned for developer machine single-node performance)
- **Topics Auto-Create**: Enabled (`auto.create.topics.enable=true`)

### 3. Redis
- **Authentication**: Disabled by default in development mode (`protected-mode no`).
- **Memory Limit**: `256mb`
- **Eviction Policy**: `allkeys-lru` (Evicts the least recently used keys when memory limit is reached)
- **Persistence**: Snapshotting enabled (`save 300 100`). Append-Only File (AOF) is disabled to optimize disk write overhead.

### 4. Elasticsearch
- **JVM Options**: `-Xms512m -Xmx512m` (Tuned to fit within standard development hardware limits)
- **Discovery Type**: `single-node`
- **CORS Allowed Origins**: `*` (Configured to enable connection from local frontend debug consoles)
