# Storage Integration Guidelines

This document details the file storage conventions and rules required by all microservices when reading or writing persistent files.

## Container Filesystem Convention
Every service requiring file storage or generation must mount `./shared/storage/` to `/data` inside the container. 

## Directory Mapping Rules

1.  **Write Only Within `/data`**:
    No service should ever write files directly to `/tmp`, `/root`, `/home`, or other random internal paths. All writes must target one of the standard directory structures:
    *   `/data/uploads/` - Raw files uploaded by users.
    *   `/data/filestore/` - Managed persistent documents.
    *   `/data/pdfs/` - PDF bills, receipts, certificates.
    *   `/data/exports/` - Excel/CSV sheets generated dynamically.
    *   `/data/temp/` - Ephemeral files, logs, or processing buffers.

2.  **No Native Path Dependencies**:
    Do not use Windows backslashes (`\`) or absolute machine paths (`C:\Users\...` or `/Users/name/...`) in configurations or source code. Use unix-style relative forwarding paths (e.g. `/data/uploads/file.txt`).

3.  **Permissions Safety**:
    Host directories are initialized with `chmod 777` permissions during the bootstrap phase (`scripts/bootstrap.sh`) to prevent permission errors on Linux/macOS host machines. Avoid modifying directory ownership parameters inside container startup scripts.
