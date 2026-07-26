# Shared Storage Directory

This folder represents the standard persistent filesystem for all microservices in the environment.

## Container Mapping
All microservices must mount this directory to `/data` inside their containers.

## Subdirectories
*   [`uploads/`](file:///f:/digit%20infrastructure/shared/storage/uploads/): Target folder for raw files uploaded by users.
*   [`filestore/`](file:///f:/digit%20infrastructure/shared/storage/filestore/): Long-term system files managed by the filestore service.
*   [`pdfs/`](file:///f:/digit%20infrastructure/shared/storage/pdfs/): Generated receipts, licenses, and certificates.
*   [`exports/`](file:///f:/digit%20infrastructure/shared/storage/exports/): Temporarily exported search results or tables.
*   [`temp/`](file:///f:/digit%20infrastructure/shared/storage/temp/): Cache files or short-lived system documents.

No service should ever write files to path structures outside of `/data`.
