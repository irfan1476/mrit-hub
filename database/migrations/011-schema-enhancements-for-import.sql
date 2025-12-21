-- Migration 011: Schema Enhancements for MRIT Data Import
-- Align schema with mrit.sql structure

-- Add designation table
CREATE TABLE designation (
    id SERIAL PRIMARY KEY,
    des_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Add job_role table  
CREATE TABLE job_role (
    id SERIAL PRIMARY KEY,
    job_role VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Enhance faculty table
ALTER TABLE faculty 
ADD COLUMN employee_id VARCHAR(10) UNIQUE,
ADD COLUMN dept_id INTEGER REFERENCES department(id),
ADD COLUMN designation_id INTEGER REFERENCES designation(id),
ADD COLUMN job_role_id INTEGER REFERENCES job_role(id);

-- Update phone field lengths
ALTER TABLE faculty ALTER COLUMN phone TYPE VARCHAR(12);
ALTER TABLE student_data ALTER COLUMN phone TYPE VARCHAR(12);
ALTER TABLE student_data ALTER COLUMN father_phone TYPE VARCHAR(12);
ALTER TABLE student_data ALTER COLUMN alt_phone TYPE VARCHAR(12);
ALTER TABLE student_data ALTER COLUMN parent_primary_phone TYPE VARCHAR(12);

-- Add missing student fields
ALTER TABLE student_data 
ADD COLUMN sec_name VARCHAR(5),
ADD COLUMN cur_semester_id INTEGER REFERENCES semester(id),
ADD COLUMN cur_aca_yr INTEGER REFERENCES academic_year(id),
ADD COLUMN cur_scheme_id INTEGER REFERENCES scheme(id);

-- Drop existing course table and recreate to match mrit.sql structure
DROP TABLE IF EXISTS course_offering CASCADE;
DROP TABLE IF EXISTS course CASCADE;

CREATE TABLE course (
    id SERIAL PRIMARY KEY,
    course_code VARCHAR(30) NOT NULL,
    course_name VARCHAR(200) NOT NULL,
    branch VARCHAR(20),
    semester INTEGER,
    lecture_hours INTEGER DEFAULT 0,
    tutorial_hours INTEGER DEFAULT 0,
    practical_hours INTEGER DEFAULT 0,
    cie_marks INTEGER DEFAULT 50,
    see_marks INTEGER DEFAULT 50,
    credits INTEGER DEFAULT 3,
    scheme_year INTEGER,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Recreate course_offering with new structure
CREATE TABLE course_offering (
    id SERIAL PRIMARY KEY,
    course_id INTEGER REFERENCES course(id) ON DELETE CASCADE,
    faculty_id INTEGER REFERENCES faculty(id),
    academic_year_id INTEGER REFERENCES academic_year(id),
    section_id INTEGER REFERENCES section(id),
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Add indexes
CREATE INDEX idx_faculty_employee_id ON faculty(employee_id);
CREATE INDEX idx_faculty_dept ON faculty(dept_id);
CREATE INDEX idx_student_sec_name ON student_data(sec_name);
CREATE INDEX idx_student_cur_semester ON student_data(cur_semester_id);
CREATE INDEX idx_course_code ON course(course_code);
CREATE INDEX idx_course_scheme_year ON course(scheme_year);
CREATE INDEX idx_course_semester ON course(semester);

-- Add triggers
CREATE TRIGGER update_course_offering_updated_at BEFORE UPDATE ON course_offering
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert common designations
INSERT INTO designation (des_name) VALUES
('Professor'),
('Associate Professor'),
('Assistant Professor'),
('Lecturer'),
('Lab Assistant'),
('HOD'),
('Principal'),
('Vice Principal');

-- Insert common job roles
INSERT INTO job_role (job_role) VALUES
('Teaching Faculty'),
('Non-Teaching Staff'),
('Administrative Staff'),
('Lab Staff'),
('Management');