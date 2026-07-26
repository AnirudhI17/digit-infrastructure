-- User database schema DDL
CREATE TABLE IF NOT EXISTS eg_user (
    id VARCHAR(64) PRIMARY KEY,
    username VARCHAR(128) NOT NULL UNIQUE,
    email VARCHAR(256),
    active BOOLEAN DEFAULT TRUE,
    created_time BIGINT
);

CREATE INDEX IF NOT EXISTS idx_eg_user_username ON eg_user(username);
