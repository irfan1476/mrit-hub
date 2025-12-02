-- Seed data for leave management system
-- Migration 008: Add sample leave balances and faculty data

-- Insert sample leave balances for existing faculty (assuming faculty IDs 1-5 exist)
INSERT INTO leave_balance (faculty_id, leave_type_id, academic_year_id, opening_balance, used_days, remaining_days) 
SELECT 
    f.faculty_id,
    lt.id,
    1, -- Current academic year
    CASE 
        WHEN lt.code = 'CL' THEN 12
        WHEN lt.code = 'SCL' THEN 6
        WHEN lt.code = 'EL' THEN 30
        WHEN lt.code = 'VL' THEN 45
        WHEN lt.code = 'OD' THEN 365
        WHEN lt.code = 'TEST' THEN 5
        WHEN lt.code = 'COMMIT' THEN 10
        WHEN lt.code = 'RH' THEN 8
        WHEN lt.code = 'OCL' THEN 15
        ELSE 0
    END as opening_balance,
    0 as used_days,
    CASE 
        WHEN lt.code = 'CL' THEN 12
        WHEN lt.code = 'SCL' THEN 6
        WHEN lt.code = 'EL' THEN 30
        WHEN lt.code = 'VL' THEN 45
        WHEN lt.code = 'OD' THEN 365
        WHEN lt.code = 'TEST' THEN 5
        WHEN lt.code = 'COMMIT' THEN 10
        WHEN lt.code = 'RH' THEN 8
        WHEN lt.code = 'OCL' THEN 15
        ELSE 0
    END as remaining_days
FROM 
    (SELECT DISTINCT id as faculty_id FROM faculty LIMIT 10) f
CROSS JOIN 
    leave_type lt
WHERE 
    lt.active = true
ON CONFLICT (faculty_id, leave_type_id, academic_year_id) DO NOTHING;

-- Insert sample leave applications for testing
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
(2, 2, '2025-01-20', '2025-01-20', 0.5, 'Medical appointment', 3, 'APPROVED', 2025),
(3, 3, '2025-02-01', '2025-02-05', 5, 'Family function', 1, 'PENDING_HOD', 2025);

-- Insert corresponding approval records
INSERT INTO leave_approval (leave_application_id, approver_id, stage, decision) VALUES
(1, 2, 'SUBSTITUTE', 'PENDING'),
(1, 1, 'HOD', 'PENDING'),
(2, 3, 'SUBSTITUTE', 'APPROVED'),
(2, 1, 'HOD', 'APPROVED'),
(3, 1, 'SUBSTITUTE', 'APPROVED'),
(3, 1, 'HOD', 'PENDING');