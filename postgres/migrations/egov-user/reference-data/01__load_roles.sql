-- User roles lookup data
CREATE TABLE IF NOT EXISTS eg_role (
    code VARCHAR(64) PRIMARY KEY,
    name VARCHAR(128) NOT NULL
);

INSERT INTO eg_role (code, name) VALUES 
('SUPERUSER', 'System Administrator'),
('CITIZEN', 'Citizen user'),
('EMPLOYEE', 'Department Staff')
ON CONFLICT (code) DO NOTHING;
