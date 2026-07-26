-- Mock mdms config table migration script
CREATE TABLE IF NOT EXISTS eg_mdms_schema (
    code VARCHAR(128) PRIMARY KEY,
    module_name VARCHAR(128) NOT NULL,
    active BOOLEAN DEFAULT TRUE
);
