-- Migration 012: Import Timetable and Infrastructure Data for Attendance
-- Create schemas and tables for timetable and room management

-- ============================================================================
-- INFRASTRUCTURE SCHEMA
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS infra;

-- Room types
CREATE TABLE IF NOT EXISTS infra.room_type (
    id SERIAL PRIMARY KEY,
    room_type VARCHAR(50) NOT NULL,
    room_code VARCHAR(20)
);

-- Floor information
CREATE TABLE IF NOT EXISTS infra.floor (
    id SERIAL PRIMARY KEY,
    floor_name VARCHAR(50) NOT NULL,
    floor_code VARCHAR(10)
);

-- Room numbers
CREATE TABLE IF NOT EXISTS infra.room_number (
    id SERIAL PRIMARY KEY,
    room_number VARCHAR(20) NOT NULL,
    room_type_id INTEGER REFERENCES infra.room_type(id),
    floor_id INTEGER REFERENCES infra.floor(id),
    description VARCHAR(200),
    capacity INTEGER DEFAULT 60,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Room allotment to departments
CREATE TABLE IF NOT EXISTS infra.room_allotment (
    id SERIAL PRIMARY KEY,
    room_number_id INTEGER REFERENCES infra.room_number(id),
    dept_id INTEGER REFERENCES department(id),
    room_area INTEGER,
    remarks VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- TIMETABLE SCHEMA  
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS time_table;

-- Weekdays
CREATE TABLE IF NOT EXISTS time_table.weekday (
    id SERIAL PRIMARY KEY,
    weekday VARCHAR(10) NOT NULL,
    day_order INTEGER
);

-- Class periods/time slots
CREATE TABLE IF NOT EXISTS time_table.class_period (
    id SERIAL PRIMARY KEY,
    period_name VARCHAR(10) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    period_order INTEGER
);

-- Main timetable
CREATE TABLE IF NOT EXISTS time_table.timetable (
    id SERIAL PRIMARY KEY,
    academic_year_id INTEGER REFERENCES academic_year(id),
    semester_id INTEGER REFERENCES semester(id),
    branch_id INTEGER REFERENCES department(id),
    scheme_id INTEGER REFERENCES scheme(id),
    section_id INTEGER REFERENCES section(id),
    weekday_id INTEGER REFERENCES time_table.weekday(id),
    class_period_id INTEGER REFERENCES time_table.class_period(id),
    course_id INTEGER REFERENCES course(id),
    faculty_id INTEGER REFERENCES faculty(id),
    room_number_id INTEGER REFERENCES infra.room_number(id),
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(academic_year_id, semester_id, section_id, weekday_id, class_period_id)
);

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_room_number_active ON infra.room_number(active);
CREATE INDEX IF NOT EXISTS idx_room_allotment_dept ON infra.room_allotment(dept_id);
CREATE INDEX IF NOT EXISTS idx_timetable_section ON time_table.timetable(section_id);
CREATE INDEX IF NOT EXISTS idx_timetable_faculty ON time_table.timetable(faculty_id);
CREATE INDEX IF NOT EXISTS idx_timetable_course ON time_table.timetable(course_id);
CREATE INDEX IF NOT EXISTS idx_timetable_room ON time_table.timetable(room_number_id);
CREATE INDEX IF NOT EXISTS idx_timetable_active ON time_table.timetable(active);

-- ============================================================================
-- SEED DATA
-- ============================================================================

-- Insert weekdays
INSERT INTO time_table.weekday (weekday, day_order) VALUES
('Monday', 1), ('Tuesday', 2), ('Wednesday', 3), ('Thursday', 4), ('Friday', 5), ('Saturday', 6)
ON CONFLICT DO NOTHING;

-- Insert MRIT time slots (9:15 AM - 4:15 PM)
INSERT INTO time_table.class_period (period_name, start_time, end_time, period_order) VALUES
('1st Hour', '09:15:00', '10:15:00', 1),
('2nd Hour', '10:15:00', '11:15:00', 2),
('3rd Hour', '11:30:00', '12:30:00', 3),
('4th Hour', '12:30:00', '13:30:00', 4),
('5th Hour', '14:15:00', '15:15:00', 5),
('6th Hour', '15:15:00', '16:15:00', 6)
ON CONFLICT DO NOTHING;

-- Insert room types
INSERT INTO infra.room_type (room_type, room_code) VALUES
('Classroom', 'CR'),
('Laboratory', 'LAB'),
('Seminar Hall', 'SH'),
('Auditorium', 'AUD'),
('Staff Room', 'SR')
ON CONFLICT DO NOTHING;

-- Insert floors
INSERT INTO infra.floor (floor_name, floor_code) VALUES
('Ground Floor', 'GF'),
('First Floor', '1F'),
('Second Floor', '2F'),
('Third Floor', '3F'),
('Fourth Floor', '4F')
ON CONFLICT DO NOTHING;