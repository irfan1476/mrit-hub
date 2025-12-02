-- Migration 006: Add Timetable Structure and Class Types
-- Adds support for different class types (Theory, Lab, Tutorial) and timetable management

-- 1. Create time_slot table for different class periods
CREATE TABLE time_slot (
    id SERIAL PRIMARY KEY,
    slot_name VARCHAR(50) NOT NULL,        -- "Period 1", "Lab Session A", "MRIT Hour"
    start_time TIME NOT NULL,              -- 09:00:00
    end_time TIME NOT NULL,                -- 10:00:00 or 12:00:00 for labs
    duration_hours INTEGER NOT NULL,       -- 1 for theory, 2-3 for labs
    slot_type VARCHAR(20) NOT NULL CHECK (slot_type IN ('THEORY', 'LAB', 'TUTORIAL', 'SEMINAR')),
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 2. Create timetable table for weekly schedule
CREATE TABLE timetable (
    id SERIAL PRIMARY KEY,
    course_offering_id INTEGER REFERENCES course_offering(id) ON DELETE CASCADE,
    day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 1 AND 7), -- 1=Monday, 7=Sunday
    time_slot_id INTEGER REFERENCES time_slot(id),
    room_number VARCHAR(20),
    effective_from DATE NOT NULL,
    effective_to DATE,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 3. Add missing columns to attendance_session for better class tracking
ALTER TABLE attendance_session ADD COLUMN time_slot_id INTEGER REFERENCES time_slot(id);
ALTER TABLE attendance_session ADD COLUMN duration_hours INTEGER DEFAULT 1;
ALTER TABLE attendance_session ADD COLUMN class_type VARCHAR(20) DEFAULT 'THEORY';
ALTER TABLE attendance_session ADD COLUMN room_number VARCHAR(20);
ALTER TABLE attendance_session ADD COLUMN department_id INTEGER REFERENCES department(id);
ALTER TABLE attendance_session ADD COLUMN semester_id INTEGER REFERENCES semester(id);
ALTER TABLE attendance_session ADD COLUMN section_id INTEGER REFERENCES section(id);
ALTER TABLE attendance_session ADD COLUMN subject_code VARCHAR(10);

-- 4. Insert sample time slots
INSERT INTO time_slot (slot_name, start_time, end_time, duration_hours, slot_type) VALUES
-- Regular Theory Periods (1 hour each)
('Period 1', '09:00:00', '10:00:00', 1, 'THEORY'),
('Period 2', '10:00:00', '11:00:00', 1, 'THEORY'),
('Period 3', '11:15:00', '12:15:00', 1, 'THEORY'),
('Period 4', '12:15:00', '13:15:00', 1, 'THEORY'),
('Period 5', '14:00:00', '15:00:00', 1, 'THEORY'),
('Period 6', '15:00:00', '16:00:00', 1, 'THEORY'),
('Period 7', '16:00:00', '17:00:00', 1, 'THEORY'),

-- Special Periods
('MRIT Hour', '12:30:00', '13:30:00', 1, 'THEORY'),

-- Lab Sessions (2-3 hours each)
('Lab Session A (Morning)', '09:00:00', '12:00:00', 3, 'LAB'),
('Lab Session B (Afternoon)', '14:00:00', '17:00:00', 3, 'LAB'),
('Lab Session C (Extended)', '09:00:00', '11:00:00', 2, 'LAB'),
('Lab Session D (Extended)', '14:00:00', '16:00:00', 2, 'LAB'),

-- Tutorial Sessions
('Tutorial A', '11:00:00', '12:00:00', 1, 'TUTORIAL'),
('Tutorial B', '15:00:00', '16:00:00', 1, 'TUTORIAL');

-- 5. Create indexes for performance
CREATE INDEX idx_timetable_course_offering ON timetable(course_offering_id);
CREATE INDEX idx_timetable_day_slot ON timetable(day_of_week, time_slot_id);
CREATE INDEX idx_timetable_active ON timetable(active);
CREATE INDEX idx_time_slot_type ON time_slot(slot_type);
CREATE INDEX idx_attendance_session_time_slot ON attendance_session(time_slot_id);
CREATE INDEX idx_attendance_session_dept_sem_sec ON attendance_session(department_id, semester_id, section_id);

-- 6. Add trigger for timetable updated_at
CREATE TRIGGER update_timetable_updated_at BEFORE UPDATE ON timetable
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 7. Sample courses for CSE 3rd Semester (for testing)
INSERT INTO course (code, course_name, credit, scheme_id, semester_id, dept_id, course_cat_id) VALUES
-- Theory Courses
('21CS31', 'Data Structures and Applications', 4, 5, 3, 6, 4), -- PCC
('21CS32', 'Computer Organization', 4, 5, 3, 6, 4),
('21CS33', 'Analog and Digital Electronics', 4, 5, 3, 6, 2), -- ESC
('21MAT31', 'Transform Calculus', 4, 5, 3, 3, 1), -- BSC
('21KSK31', 'Kannada', 1, 5, 3, 4, 3), -- HSMC

-- Lab Courses (2-3 hours)
('21CSL31', 'Data Structures Laboratory', 2, 5, 3, 6, 4),
('21CSL32', 'Computer Organization Laboratory', 2, 5, 3, 6, 4),
('21AESL31', 'Analog and Digital Electronics Laboratory', 2, 5, 3, 6, 2);

COMMENT ON TABLE time_slot IS 'Defines different time periods for classes - theory (1hr), labs (2-3hrs), tutorials';
COMMENT ON TABLE timetable IS 'Weekly schedule mapping courses to time slots and rooms';
COMMENT ON COLUMN attendance_session.class_type IS 'THEORY, LAB, TUTORIAL, SEMINAR - determines attendance rules';
COMMENT ON COLUMN attendance_session.duration_hours IS 'Class duration - 1 for theory, 2-3 for labs';