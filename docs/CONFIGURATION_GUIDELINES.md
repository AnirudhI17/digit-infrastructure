# Configuration Management Guidelines

This page outlines the rules for service properties and parameter configurations.

## Centralized Configurations
To ensure all configuration files are version-controlled, clean, and shared across services, all YAML/properties/JSON files must be stored in `./shared/config/`.

## Directory Conventions
*   `/config/application/`: Service configuration properties (e.g. `application.yml`).
*   `/config/mdms/`: Global configuration files, json parameters, and schemas managed by MDMS.
*   `/config/localization/`: Default translations dictionary records.
*   `/config/workflow/`: Business transition states rules and JSON matrices.
*   `/config/schemas/`: Validation JSON/XML schemas.

## Configuration Loading Rules

1.  **Mount Location**:
    Configure your Docker container to mount the shared directory as read-only:
    `./shared/config:/config:ro`

2.  **Referencing in Microservices**:
    Read settings from the mounted directory path. For example, in Spring Boot:
    ```properties
    spring.config.additional-location=file:/config/application/
    ```
    For Node.js or Go:
    ```javascript
    const configPath = process.env.CONFIG_PATH || '/config/application/config.json';
    ```

3.  **Environment Variable Overrides**:
    Never hardcode secrets (passwords, private API tokens) in the properties files inside the repository. Instead, reference them using environment variables (e.g. `${POSTGRES_PASSWORD}`) that are defined in `.env` and loaded at runtime.
