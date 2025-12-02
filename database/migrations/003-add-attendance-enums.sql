-- Create enum types for attendance system
CREATE TYPE session_status_enum AS ENUM ('SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED');
CREATE TYPE attendance_status_enum AS ENUM ('PRESENT', 'ABSENT', 'LATE', 'EXCUSED');
CREATE TYPE log_action_enum AS ENUM ('CREATED', 'UPDATED', 'DELETED');
CREATE TYPE template_type_enum AS ENUM ('ABSENCE_ALERT', 'DEFAULTER_WARNING', 'ATTENDANCE_SUMMARY', 'GENERAL_NOTIFICATION');
CREATE TYPE sms_status_enum AS ENUM ('PENDING', 'SENT', 'DELIVERED', 'FAILED', 'REJECTED');

-- Update attendance_session table with new columns and constraints
ALTER TABLE attendance_session 
ADD COLUMN IF NOT EXISTS status session_status_enum DEFAULT 'SCHEDULED',
ADD COLUMN IF NOT EXISTS topic VARCHAR(255),
ADD COLUMN IF NOT EXISTS notes TEXT,
ADD COLUMN IF NOT EXISTS total_students INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS present_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS absent_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS sms_sent BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS completed_at TIMESTAMP,
ADD COLUMN IF NOT EXISTS edit_deadline TIMESTAMP;

-- Update attendance_record table with new columns
ALTER TABLE attendance_record 
ADD COLUMN IF NOT EXISTS status attendance_status_enum NOT NULL DEFAULT 'ABSENT',
ADD COLUMN IF NOT EXISTS marked_at_time TIME,
ADD COLUMN IF NOT EXISTS marked_by_faculty_id INTEGER,
ADD COLUMN IF NOT EXISTS remarks TEXT,
ADD COLUMN IF NOT EXISTS is_edited BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS last_edited_at TIMESTAMP,
ADD COLUMN IF NOT EXISTS last_edited_by INTEGER;

-- Update attendance_log table with new columns
ALTER TABLE attendance_log 
ADD COLUMN IF NOT EXISTS action log_action_enum NOT NULL DEFAULT 'CREATED',
ADD COLUMN IF NOT EXISTS old_status attendance_status_enum,
ADD COLUMN IF NOT EXISTS new_status attendance_status_enum,
ADD COLUMN IF NOT EXISTS old_remarks TEXT,
ADD COLUMN IF NOT EXISTS new_remarks TEXT,
ADD COLUMN IF NOT EXISTS changed_by_faculty_id INTEGER NOT NULL,
ADD COLUMN IF NOT EXISTS reason TEXT,
ADD COLUMN IF NOT EXISTS ip_address INET,
ADD COLUMN IF NOT EXISTS user_agent TEXT;

-- Update attendance_summary table with new columns
ALTER TABLE attendance_summary 
ADD COLUMN IF NOT EXISTS present_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS absent_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS late_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS excused_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS attendance_percentage DECIMAL(5,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS last_attendance_date DATE,
ADD COLUMN IF NOT EXISTS is_defaulter BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS required_percentage DECIMAL(5,2) DEFAULT 75.0;

-- Update sms_template table with new columns
ALTER TABLE sms_template 
ADD COLUMN IF NOT EXISTS template_name VARCHAR(255) UNIQUE,
ADD COLUMN IF NOT EXISTS template_type template_type_enum NOT NULL DEFAULT 'GENERAL_NOTIFICATION',
ADD COLUMN IF NOT EXISTS message_template TEXT NOT NULL,
ADD COLUMN IF NOT EXISTS description TEXT,
ADD COLUMN IF NOT EXISTS variables JSON,
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS dlt_template_id VARCHAR(255),
ADD COLUMN IF NOT EXISTS sender_id VARCHAR(255);

-- Update sms_log table with new columns
ALTER TABLE sms_log 
ADD COLUMN IF NOT EXISTS phone_number VARCHAR(15) NOT NULL,
ADD COLUMN IF NOT EXISTS message TEXT NOT NULL,
ADD COLUMN IF NOT EXISTS status sms_status_enum DEFAULT 'PENDING',
ADD COLUMN IF NOT EXISTS template_id INTEGER,
ADD COLUMN IF NOT EXISTS student_id INTEGER,
ADD COLUMN IF NOT EXISTS session_id INTEGER,
ADD COLUMN IF NOT EXISTS gateway_message_id VARCHAR(255),
ADD COLUMN IF NOT EXISTS gateway_response TEXT,
ADD COLUMN IF NOT EXISTS error_message TEXT,
ADD COLUMN IF NOT EXISTS sent_at TIMESTAMP,
ADD COLUMN IF NOT EXISTS delivered_at TIMESTAMP,
ADD COLUMN IF NOT EXISTS retry_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS cost DECIMAL(10,4);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_attendance_session_faculty_date ON attendance_session(faculty_id, session_date);
CREATE INDEX IF NOT EXISTS idx_attendance_session_status ON attendance_session(status);
CREATE INDEX IF NOT EXISTS idx_attendance_record_session_student ON attendance_record(session_id, student_id);
CREATE INDEX IF NOT EXISTS idx_attendance_record_status ON attendance_record(status);
CREATE INDEX IF NOT EXISTS idx_attendance_summary_student_course ON attendance_summary(student_id, course_id, academic_year_id);
CREATE INDEX IF NOT EXISTS idx_attendance_summary_defaulter ON attendance_summary(is_defaulter);
CREATE INDEX IF NOT EXISTS idx_sms_log_status ON sms_log(status);
CREATE INDEX IF NOT EXISTS idx_sms_log_phone ON sms_log(phone_number);

-- Add foreign key constraints
ALTER TABLE attendance_record 
ADD CONSTRAINT IF NOT EXISTS fk_attendance_record_session 
FOREIGN KEY (session_id) REFERENCES attendance_session(id) ON DELETE CASCADE;

ALTER TABLE attendance_log 
ADD CONSTRAINT IF NOT EXISTS fk_attendance_log_record 
FOREIGN KEY (attendance_record_id) REFERENCES attendance_record(id) ON DELETE CASCADE;

-- Insert default SMS templates
INSERT INTO sms_template (template_name, template_type, message_template, description, variables, dlt_template_id) 
VALUES 
('absence_alert', 'ABSENCE_ALERT', 
 'Dear Parent, Your ward {student_name} (Roll: {roll_number}) was absent for {subject} on {date} at {time}. Please contact college if this is incorrect. - MRIT',
 'SMS sent to parents when student is marked absent',
 '["student_name", "roll_number", "subject", "date", "time"]',
 'DLT_TEMPLATE_001'),
 
('defaulter_warning', 'DEFAULTER_WARNING',
 'Dear Parent, Your ward {student_name} (Roll: {roll_number}) has {attendance_percentage}% attendance in {subject}. Minimum required: 75%. Please ensure regular attendance. - MRIT',
 'SMS sent when student becomes defaulter',
 '["student_name", "roll_number", "attendance_percentage", "subject"]',
 'DLT_TEMPLATE_002')
ON CONFLICT (template_name) DO NOTHING;