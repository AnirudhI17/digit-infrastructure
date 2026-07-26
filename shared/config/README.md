# Shared Configurations Directory

This directory is the single source of truth for configuration files across the entire platform.

## Container Mapping
All microservices must mount this directory to `/config` inside their containers.

## Subdirectories
*   [`application/`](file:///f:/digit%20infrastructure/shared/config/application/): Holds service-specific property configurations (e.g. `application.yml`, `bootstrap.properties`).
*   [`mdms/`](file:///f:/digit%20infrastructure/shared/config/mdms/): Master Data Management Service json data schemas.
*   [`localization/`](file:///f:/digit%20infrastructure/shared/config/localization/): Default language translation files.
*   [`workflow/`](file:///f:/digit%20infrastructure/shared/config/workflow/): Business workflow configurations.
*   [`schemas/`](file:///f:/digit%20infrastructure/shared/config/schemas/): Validation schemas (JSON/XML/etc.) used to enforce messaging payloads.
