# Platform Architecture Overview

This document describes the architectural layout of the shared development infrastructure stack for the DIGIT platform, detailing how microservices communicate and access shared persistence channels.

## Platform Boundaries

```mermaid
flowchart TD
    subgraph Host Workstation
        subgraph Developer Environment [Infrastructure Namespace]
            DB[(PostgreSQL)]
            Cache[(Redis)]
            ES[(Elasticsearch)]
            ZK[Zookeeper]
            KF[Kafka Broker]
        end

        subgraph Local Shared Directories
            Storage["shared/storage (Mounted: /data)"]
            Config["shared/config (Mounted: /config)"]
            Logs["shared/logs (Mounted: /var/log)"]
        end

        subgraph DIGIT Services [Microservices Space]
            SVC1[User Service] --> DB
            SVC1 --> Cache
            SVC1 -.-> Storage
            SVC1 -.-> Config
            SVC2[Localization Service] --> DB
            SVC2 --> Cache
            SVC2 -.-> Config
            SVC3[Billing Service] --> DB
            SVC3 --> KF
            SVC3 -.-> Config
            SVC4[Search Indexer] --> KF
            SVC4 --> ES
            SVC4 -.-> Storage
        end
    end

    KF <--> ZK
```

## Shared Services Directory Mapping

All services are built to communicate purely via container-to-container channels utilizing container names as host identifiers:

*   **Database Host**: `postgres` (Port `5432`)
*   **Cache Store**: `redis` (Port `6379`)
*   **Event Broker**: `kafka` (Port `29092` internal, `9092` external host)
*   **Indexing Engine**: `elasticsearch` (Port `9200`)

By mapping local directories:
- `./shared/storage` to `/data` in container runtimes.
- `./shared/config` to `/config` in container runtimes.

We eliminate absolute dependencies on any specific developer's local filesystem paths, allowing instant deployment portability between Linux, macOS, and Windows workstation platforms.
