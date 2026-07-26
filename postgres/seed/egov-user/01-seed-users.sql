-- Mock seed inserts for user tables
INSERT INTO eg_user (id, username, email, active, created_time) 
VALUES ('usr-001', 'system_admin', 'admin@digit.org', true, 1690372800)
ON CONFLICT (id) DO NOTHING;
