-- Leave Management System Schema
-- Migration 007: Create leave management tables

-- Leave types configuration
CREATE TABLE leave_type (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(20) NOT NULL UNIQUE,
    allow_half_day BOOLEAN DEFAULT true,
    requires_substitute BOOLEAN DEFAULT true,
    max_days_per_year NUMERIC(5,1) DEFAULT NULL,
    is_paid BOOLEAN DEFAULT true,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);

-- Leave balance tracking per faculty per year
CREATE TABLE leave_balance (
    id SERIAL PRIMARY KEY,
    faculty_id INTEGER NOT NULL REFERENCES faculty(id),
    leave_type_id INTEGER NOT NULL REFERENCES leave_type(id),
    academic_year_id INTEGER NOT NULL REFERENCES academic_year(id),
    opening_balance NUMERIC(5,1) DEFAULT 0,
    used_days NUMERIC(5,1) DEFAULT 0,
    remaining_days NUMERIC(5,1) DEFAULT 0,
    last_updated TIMESTAMP DEFAULT now(),
    UNIQUE(faculty_id, leave_type_id, academic_year_id)
);

-- Leave application status enum
CREATE TYPE leave_status_enum AS ENUM (
    'DRAFT',
    'PENDING_SUBSTITUTE', 
    'PENDING_HOD',
    'APPROVED',
    'REJECTED',
    'CANCELLED'
);

-- Leave applications
CREATE TABLE leave_application (
    id SERIAL PRIMARY KEY,
    faculty_id INTEGER NOT NULL REFERENCES faculty(id),
    leave_type_id INTEGER NOT NULL REFERENCES leave_type(id),
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    total_days NUMERIC(3,1) NOT NULL CHECK (total_days >= 0.5),
    reason TEXT NOT NULL,
    substitute_faculty_id INTEGER REFERENCES faculty(id),
    hod_id INTEGER REFERENCES faculty(id),
    status leave_status_enum DEFAULT 'PENDING_SUBSTITUTE',
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now(),
    policy_name VARCHAR(100),
    policy_year INTEGER,
    CONSTRAINT valid_date_range CHECK (from_date <= to_date)
);

-- Approval workflow stages
CREATE TYPE approval_stage_enum AS ENUM ('SUBSTITUTE', 'HOD');
CREATE TYPE approval_decision_enum AS ENUM ('PENDING', 'APPROVED', 'REJECTED');

-- Leave approvals tracking
CREATE TABLE leave_approval (
    id SERIAL PRIMARY KEY,
    leave_application_id INTEGER NOT NULL REFERENCES leave_application(id) ON DELETE CASCADE,
    approver_id INTEGER NOT NULL REFERENCES faculty(id),
    stage approval_stage_enum NOT NULL,
    decision approval_decision_enum DEFAULT 'PENDING',
    comment TEXT,
    decided_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT now(),
    UNIQUE(leave_application_id, stage)
);

-- Indexes for performance
CREATE INDEX idx_leave_balance_faculty ON leave_balance(faculty_id);
CREATE INDEX idx_leave_balance_year ON leave_balance(academic_year_id);
CREATE INDEX idx_leave_application_faculty ON leave_application(faculty_id);
CREATE INDEX idx_leave_application_status ON leave_application(status);
CREATE INDEX idx_leave_application_dates ON leave_application(from_date, to_date);
CREATE INDEX idx_leave_approval_approver ON leave_approval(approver_id);
CREATE INDEX idx_leave_approval_stage ON leave_approval(stage, decision);

-- Triggers for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_leave_type_updated_at BEFORE UPDATE ON leave_type FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_leave_balance_updated_at BEFORE UPDATE ON leave_balance FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_leave_application_updated_at BEFORE UPDATE ON leave_application FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert default leave types
INSERT INTO leave_type (name, code, allow_half_day, requires_substitute, max_days_per_year, is_paid) VALUES
('Casual Leave', 'CL', true, true, 12, true),
('Special Casual Leave', 'SCL', true, true, 6, true),
('Earned Leave', 'EL', true, true, 30, true),
('Vacation Leave', 'VL', false, false, NULL, true),
('On Official Duty', 'OD', true, false, NULL, true),
('Testing - Dummy', 'TEST', true, true, NULL, true),
('Committed Leaves', 'COMMIT', true, true, NULL, true),
('Restricted Holiday', 'RH', false, false, NULL, true),
('Off-Campus Leave', 'OCL', true, true, NULL, true);