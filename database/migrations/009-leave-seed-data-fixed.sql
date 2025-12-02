-- Fixed seed data for leave management system
-- Migration 009: Add sample leave applications with correct faculty IDs

-- Insert sample leave applications for testing (using existing faculty IDs)
INSERT INTO leave_application (
    faculty_id, 
    leave_type_id, 
    from_date, 
    to_date, 
    total_days, 
    reason, 
    substitute_faculty_id, 
    status, 
    policy_year
) VALUES 
(1, 1, '2025-01-15', '2025-01-16', 2, 'Personal work', 2, 'PENDING_SUBSTITUTE', 2025),
(2, 2, '2025-01-20', '2025-01-20', 0.5, 'Medical appointment', 1, 'APPROVED', 2025),
(1, 3, '2025-02-01', '2025-02-05', 5, 'Family function', 2, 'PENDING_HOD', 2025);

-- Get the application IDs for approval records
DO $$
DECLARE
    app1_id INTEGER;
    app2_id INTEGER;
    app3_id INTEGER;
BEGIN
    SELECT id INTO app1_id FROM leave_application WHERE faculty_id = 1 AND from_date = '2025-01-15';
    SELECT id INTO app2_id FROM leave_application WHERE faculty_id = 2 AND from_date = '2025-01-20';
    SELECT id INTO app3_id FROM leave_application WHERE faculty_id = 1 AND from_date = '2025-02-01';
    
    -- Insert corresponding approval records
    INSERT INTO leave_approval (leave_application_id, approver_id, stage, decision) VALUES
    (app1_id, 2, 'SUBSTITUTE', 'PENDING'),
    (app1_id, 1, 'HOD', 'PENDING'),
    (app2_id, 1, 'SUBSTITUTE', 'APPROVED'),
    (app2_id, 1, 'HOD', 'APPROVED'),
    (app3_id, 2, 'SUBSTITUTE', 'APPROVED'),
    (app3_id, 1, 'HOD', 'PENDING');
END $$;