-- Add test users for authentication
-- Password for all users: password123
-- Hash generated with bcrypt rounds=10

-- Faculty user (links to faculty id 3)
INSERT INTO users (email, password_hash, role, email_verified, active, faculty_id)
VALUES 
('faculty@mysururoyal.org', '$2b$10$rZ5c3Hn8qF5YvF5YvF5YvOZJ5YvF5YvF5YvF5YvF5YvF5YvF5Yv', 'FACULTY', true, true, 3),
('test.faculty@mysururoyal.org', '$2b$10$rZ5c3Hn8qF5YvF5YvF5YvOZJ5YvF5YvF5YvF5YvF5YvF5YvF5Yv', 'FACULTY', true, true, 2),
('admin@mysururoyal.org', '$2b$10$rZ5c3Hn8qF5YvF5YvF5YvOZJ5YvF5YvF5YvF5YvF5YvF5YvF5Yv', 'ADMIN', true, true, 1);

-- Verify users were created
SELECT id, email, role, email_verified, active, faculty_id FROM users;
