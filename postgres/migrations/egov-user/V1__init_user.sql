-- Mock user table migration script
CREATE TABLE IF NOT EXISTS eg_user (
    id VARCHAR(64) PRIMARY KEY,
    username VARCHAR(128) NOT NULL UNIQUE,
    email VARCHAR(256),
    active BOOLEAN DEFAULT TRUE,
    created_time BIGINT
);
