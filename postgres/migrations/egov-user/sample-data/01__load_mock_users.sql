-- User database test mock users
INSERT INTO eg_user (id, username, email, active, created_time) VALUES 
('usr-001', 'system_admin', 'admin@digit.org', true, 1690372800),
('usr-002', 'citizen_test', 'citizen@digit.org', true, 1690372900)
ON CONFLICT (id) DO NOTHING;
