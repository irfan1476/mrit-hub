-- Create user role enum
CREATE TYPE user_role_enum AS ENUM ('STUDENT', 'FACULTY', 'MENTOR', 'HOD', 'ADMIN');

-- Create users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    google_sub VARCHAR(255) UNIQUE NOT NULL,
    role user_role_enum NOT NULL,
    student_id INTEGER REFERENCES student_data(id),
    faculty_id INTEGER REFERENCES faculty(id),
    active BOOLEAN DEFAULT true,
    refresh_token_hash TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_google_sub ON users(google_sub);
CREATE INDEX idx_users_role ON users(role);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();