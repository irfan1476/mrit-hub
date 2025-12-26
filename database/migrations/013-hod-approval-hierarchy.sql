-- Migration 013: HOD and Approval Hierarchy Tables
-- Critical tables for proper leave approval workflow

-- Department HOD Assignment Table
CREATE TABLE department_hod (
    id SERIAL PRIMARY KEY,
    department_id INTEGER NOT NULL REFERENCES department(id),
    faculty_id INTEGER NOT NULL REFERENCES faculty(id),
    from_date DATE NOT NULL DEFAULT CURRENT_DATE,
    to_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create partial unique index for active HODs
CREATE UNIQUE INDEX unique_active_hod_per_dept ON department_hod(department_id) WHERE is_active = TRUE;

-- Multi-level Approval Hierarchy
CREATE TABLE approval_hierarchy (
    id SERIAL PRIMARY KEY,
    department_id INTEGER REFERENCES department(id),
    level INTEGER NOT NULL,
    role_type VARCHAR(20) NOT NULL CHECK (role_type IN ('HOD', 'DEAN', 'PRINCIPAL', 'DIRECTOR')),
    designation_id INTEGER REFERENCES designation(id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_dept_hod_department ON department_hod(department_id);
CREATE INDEX idx_dept_hod_faculty ON department_hod(faculty_id);
CREATE INDEX idx_dept_hod_active ON department_hod(is_active);
CREATE INDEX idx_approval_hierarchy_dept ON approval_hierarchy(department_id);
CREATE INDEX idx_approval_hierarchy_level ON approval_hierarchy(level);

-- Triggers for updated_at
CREATE TRIGGER update_department_hod_updated_at BEFORE UPDATE ON department_hod
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_approval_hierarchy_updated_at BEFORE UPDATE ON approval_hierarchy
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert sample HOD assignments based on existing faculty with designation_id = 6
INSERT INTO department_hod (department_id, faculty_id, from_date, is_active)
SELECT DISTINCT f.dept_id, f.id, CURRENT_DATE, TRUE
FROM faculty f 
WHERE f.designation_id = 6 AND f.dept_id IS NOT NULL AND f.active = TRUE;

-- Insert default approval hierarchy (HOD level for all departments)
INSERT INTO approval_hierarchy (department_id, level, role_type, is_active)
SELECT d.id, 1, 'HOD', TRUE
FROM department d;