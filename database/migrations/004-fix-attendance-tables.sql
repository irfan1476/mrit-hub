-- Fix sms_template table structure
ALTER TABLE sms_template 
RENAME COLUMN name TO template_name;

ALTER TABLE sms_template 
RENAME COLUMN body TO message_template;

ALTER TABLE sms_template 
RENAME COLUMN active TO is_active;

-- Add missing columns to sms_template
ALTER TABLE sms_template 
ADD COLUMN IF NOT EXISTS template_type template_type_enum DEFAULT 'GENERAL_NOTIFICATION',
ADD COLUMN IF NOT EXISTS description TEXT,
ADD COLUMN IF NOT EXISTS variables JSON,
ADD COLUMN IF NOT EXISTS dlt_template_id VARCHAR(255),
ADD COLUMN IF NOT EXISTS sender_id VARCHAR(255);

-- Update sms_template to use new template_id column name
ALTER TABLE sms_template 
RENAME COLUMN template_id TO old_template_id;

-- Fix attendance_session table - add missing required columns
ALTER TABLE attendance_session 
ADD COLUMN IF NOT EXISTS faculty_id INTEGER REFERENCES faculty(id),
ADD COLUMN IF NOT EXISTS course_id INTEGER REFERENCES course(id);

-- Fix attendance_summary table - add missing required columns  
ALTER TABLE attendance_summary
ADD COLUMN IF NOT EXISTS faculty_id INTEGER REFERENCES faculty(id),
ADD COLUMN IF NOT EXISTS course_id INTEGER REFERENCES course(id);

-- Add foreign key constraints (PostgreSQL 9.6+ syntax)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_attendance_record_session') THEN
        ALTER TABLE attendance_record 
        ADD CONSTRAINT fk_attendance_record_session 
        FOREIGN KEY (session_id) REFERENCES attendance_session(id) ON DELETE CASCADE;
    END IF;
END $$;

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_attendance_log_record') THEN
        ALTER TABLE attendance_log 
        ADD CONSTRAINT fk_attendance_log_record 
        FOREIGN KEY (attendance_record_id) REFERENCES attendance_record(id) ON DELETE CASCADE;
    END IF;
END $$;

-- Insert default SMS templates with correct column names
INSERT INTO sms_template (template_name, template_type, message_template, description, variables, dlt_template_id) 
VALUES 
('absence_alert', 'ABSENCE_ALERT', 
 'Dear Parent, Your ward {student_name} (Roll: {roll_number}) was absent for {subject} on {date} at {time}. Please contact college if this is incorrect. - MRIT',
 'SMS sent to parents when student is marked absent',
 '["student_name", "roll_number", "subject", "date", "time"]'::json,
 'DLT_TEMPLATE_001'),
 
('defaulter_warning', 'DEFAULTER_WARNING',
 'Dear Parent, Your ward {student_name} (Roll: {roll_number}) has {attendance_percentage}% attendance in {subject}. Minimum required: 75%. Please ensure regular attendance. - MRIT',
 'SMS sent when student becomes defaulter',
 '["student_name", "roll_number", "attendance_percentage", "subject"]'::json,
 'DLT_TEMPLATE_002')
ON CONFLICT (template_name) DO NOTHING;