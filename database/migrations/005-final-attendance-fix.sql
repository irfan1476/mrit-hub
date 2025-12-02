-- Add attendance_record_id to attendance_log table
ALTER TABLE attendance_log 
ADD COLUMN IF NOT EXISTS attendance_record_id INTEGER;

-- Create unique constraint on template_name for sms_template
ALTER TABLE sms_template 
ADD CONSTRAINT unique_template_name UNIQUE (template_name);

-- Now add the foreign key constraint
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_attendance_log_record') THEN
        ALTER TABLE attendance_log 
        ADD CONSTRAINT fk_attendance_log_record 
        FOREIGN KEY (attendance_record_id) REFERENCES attendance_record(id) ON DELETE CASCADE;
    END IF;
END $$;

-- Insert default SMS templates (will be ignored if they exist due to unique constraint)
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

-- Verify tables are ready
SELECT 'Attendance tables updated successfully' as status;