-- MRIT Hub Database Schema
-- PostgreSQL 15+
-- Total: 27 Tables

-- ============================================================================
-- MASTER / REFERENCE TABLES
-- ============================================================================

CREATE TABLE grad_year (
    id SERIAL PRIMARY KEY,
    year INTEGER UNIQUE NOT NULL
);

CREATE TABLE gender (
    id SERIAL PRIMARY KEY,
    gender VARCHAR(10) UNIQUE NOT NULL
);

CREATE TABLE reservation (
    id SERIAL PRIMARY KEY,
    category VARCHAR(10) UNIQUE NOT NULL
);

CREATE TABLE admission (
    id SERIAL PRIMARY KEY,
    category VARCHAR(10) UNIQUE NOT NULL
);

CREATE TABLE entry (
    id SERIAL PRIMARY KEY,
    category VARCHAR(10) UNIQUE NOT NULL
);

CREATE TABLE batch (
    id SERIAL PRIMARY KEY,
    year INTEGER UNIQUE NOT NULL
);

CREATE TABLE department (
    id SERIAL PRIMARY KEY,
    code VARCHAR(5) UNIQUE NOT NULL,
    dept_name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE scheme (
    id SERIAL PRIMARY KEY,
    scheme_yr INTEGER UNIQUE NOT NULL
);

CREATE TABLE coursecat (
    id SERIAL PRIMARY KEY,
    category VARCHAR(10) UNIQUE NOT NULL
);

CREATE TABLE semester (
    id SERIAL PRIMARY KEY,
    semester INTEGER UNIQUE NOT NULL
);

CREATE TABLE academic_year (
    id SERIAL PRIMARY KEY,
    yr VARCHAR(30) UNIQUE NOT NULL
);

CREATE TABLE financial_year (
    id SERIAL PRIMARY KEY,
    yr VARCHAR(30) UNIQUE NOT NULL
);

CREATE TABLE exam_type (
    id SERIAL PRIMARY KEY,
    ex_type VARCHAR(20) UNIQUE NOT NULL
);

-- NEW: Section table
CREATE TABLE section (
    id SERIAL PRIMARY KEY,
    name VARCHAR(5) UNIQUE NOT NULL
);

-- ============================================================================
-- FACULTY & STAFF
-- ============================================================================

CREATE TABLE faculty (
    id SERIAL PRIMARY KEY,
    faculty_name VARCHAR(50) NOT NULL,
    phone BIGINT UNIQUE,
    short_name VARCHAR(5),
    email_org VARCHAR(50),
    email_personal VARCHAR(50),
    dob DATE,
    address VARCHAR(200),
    qualification VARCHAR(10),
    join_date DATE,
    pan VARCHAR(20),
    aadhar BIGINT,
    profile_photo_path VARCHAR(255),
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_faculty_active ON faculty(active);
CREATE INDEX idx_faculty_short_name ON faculty(short_name);

-- ============================================================================
-- STUDENT CORE
-- ============================================================================

CREATE TABLE student_data (
    id SERIAL PRIMARY KEY,
    usn VARCHAR(12) NOT NULL UNIQUE,
    student_name VARCHAR(50),
    branch_id INTEGER REFERENCES department(id),
    phone VARCHAR(15),
    email VARCHAR(50),
    dob DATE,
    father_name VARCHAR(50),
    father_phone VARCHAR(15),
    mother_name VARCHAR(50),
    alt_phone VARCHAR(15),
    parent_primary_phone VARCHAR(15),
    address VARCHAR(200),
    blood_group VARCHAR(5),
    profile_photo_path VARCHAR(255),
    phone_verified BOOLEAN DEFAULT FALSE,
    gender_id INTEGER REFERENCES gender(id),
    batch_id INTEGER REFERENCES batch(id),
    entry_id INTEGER REFERENCES entry(id),
    res_cat_id INTEGER REFERENCES reservation(id),
    adm_cat_id INTEGER REFERENCES admission(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_student_usn ON student_data(usn);
CREATE INDEX idx_student_branch ON student_data(branch_id);
CREATE INDEX idx_student_batch ON student_data(batch_id);

CREATE TABLE student_variables (
    id SERIAL PRIMARY KEY,
    usn VARCHAR(12) UNIQUE NOT NULL REFERENCES student_data(usn),
    grad_year_id INTEGER REFERENCES grad_year(id),
    scheme_id INTEGER REFERENCES scheme(id),
    semester_id INTEGER REFERENCES semester(id),
    section_id INTEGER REFERENCES section(id),
    mentor_id INTEGER REFERENCES faculty(id),
    year_back BOOLEAN DEFAULT FALSE,
    active BOOLEAN DEFAULT TRUE,
    notes VARCHAR(200),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_student_vars_usn ON student_variables(usn);
CREATE INDEX idx_student_vars_section ON student_variables(section_id);
CREATE INDEX idx_student_vars_mentor ON student_variables(mentor_id);
CREATE INDEX idx_student_vars_active ON student_variables(active);

CREATE TABLE placement (
    id SERIAL PRIMARY KEY,
    usn VARCHAR(12) UNIQUE NOT NULL REFERENCES student_data(usn),
    year_sslc INTEGER,
    marks_sslc NUMERIC,
    year_puc INTEGER,
    marks_puc NUMERIC,
    skills VARCHAR(250),
    live_backlog INTEGER,
    dead_backlog INTEGER,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- ACADEMIC STRUCTURE
-- ============================================================================

CREATE TABLE course (
    id SERIAL PRIMARY KEY,
    code VARCHAR(10) UNIQUE NOT NULL,
    course_name VARCHAR(100) NOT NULL,
    credit INTEGER,
    scheme_id INTEGER REFERENCES scheme(id) ON DELETE CASCADE,
    semester_id INTEGER REFERENCES semester(id) ON DELETE CASCADE,
    dept_id INTEGER REFERENCES department(id) ON DELETE CASCADE,
    course_cat_id INTEGER REFERENCES coursecat(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_course_scheme ON course(scheme_id);
CREATE INDEX idx_course_semester ON course(semester_id);
CREATE INDEX idx_course_dept ON course(dept_id);

-- NEW: Course Offering table
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

CREATE INDEX idx_offering_course ON course_offering(course_id);
CREATE INDEX idx_offering_faculty ON course_offering(faculty_id);
CREATE INDEX idx_offering_section ON course_offering(section_id);
CREATE INDEX idx_offering_active ON course_offering(active);

-- ============================================================================
-- ATTENDANCE SUBSYSTEM
-- ============================================================================

CREATE TABLE attendance_session (
    id SERIAL PRIMARY KEY,
    course_offering_id INTEGER REFERENCES course_offering(id) ON DELETE CASCADE,
    session_date DATE NOT NULL,
    period INTEGER,
    created_by INTEGER REFERENCES faculty(id),
    created_at TIMESTAMP DEFAULT NOW(),
    locked_at TIMESTAMP,
    status VARCHAR(20) DEFAULT 'open' CHECK (status IN ('open', 'locked', 'cancelled'))
);

CREATE INDEX idx_session_offering ON attendance_session(course_offering_id);
CREATE INDEX idx_session_date ON attendance_session(session_date);
CREATE INDEX idx_session_status ON attendance_session(status);

CREATE TABLE attendance_record (
    id SERIAL PRIMARY KEY,
    session_id INTEGER REFERENCES attendance_session(id) ON DELETE CASCADE,
    student_id INTEGER REFERENCES student_data(id),
    status VARCHAR(5) DEFAULT 'P' CHECK (status IN ('P', 'A', 'L', 'OD', 'M')),
    marked_by INTEGER REFERENCES faculty(id),
    marked_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP
);

CREATE INDEX idx_record_session ON attendance_record(session_id);
CREATE INDEX idx_record_student ON attendance_record(student_id);
CREATE INDEX idx_record_status ON attendance_record(status);

CREATE TABLE attendance_log (
    id SERIAL PRIMARY KEY,
    session_id INTEGER REFERENCES attendance_session(id),
    student_id INTEGER REFERENCES student_data(id),
    old_status VARCHAR(5),
    new_status VARCHAR(5),
    changed_by INTEGER REFERENCES faculty(id),
    changed_at TIMESTAMP DEFAULT NOW(),
    reason TEXT
);

CREATE INDEX idx_log_session ON attendance_log(session_id);
CREATE INDEX idx_log_student ON attendance_log(student_id);

CREATE TABLE attendance_summary (
    id SERIAL PRIMARY KEY,
    student_id INTEGER REFERENCES student_data(id),
    course_offering_id INTEGER REFERENCES course_offering(id),
    total_sessions INTEGER DEFAULT 0,
    present_sessions INTEGER DEFAULT 0,
    last_updated TIMESTAMP DEFAULT NOW(),
    UNIQUE(student_id, course_offering_id)
);

CREATE INDEX idx_summary_student ON attendance_summary(student_id);
CREATE INDEX idx_summary_offering ON attendance_summary(course_offering_id);

-- ============================================================================
-- NOTIFICATIONS SUBSYSTEM
-- ============================================================================

CREATE TABLE sms_template (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    template_id VARCHAR(100) NOT NULL,
    body TEXT NOT NULL,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE sms_log (
    id SERIAL PRIMARY KEY,
    student_id INTEGER REFERENCES student_data(id),
    parent_phone VARCHAR(15),
    template_id INTEGER REFERENCES sms_template(id),
    payload JSONB,
    provider_message_id VARCHAR(100),
    status VARCHAR(20) CHECK (status IN ('queued', 'sent', 'failed', 'delivered')),
    error_message TEXT,
    sent_at TIMESTAMP,
    delivered_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_sms_student ON sms_log(student_id);
CREATE INDEX idx_sms_status ON sms_log(status);
CREATE INDEX idx_sms_sent_at ON sms_log(sent_at);

CREATE TABLE notification_preference (
    id SERIAL PRIMARY KEY,
    student_id INTEGER UNIQUE REFERENCES student_data(id),
    sms_absent_alert BOOLEAN DEFAULT TRUE,
    email_absent_alert BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- TRIGGERS FOR UPDATED_AT
-- ============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_faculty_updated_at BEFORE UPDATE ON faculty
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_student_data_updated_at BEFORE UPDATE ON student_data
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_student_variables_updated_at BEFORE UPDATE ON student_variables
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_course_offering_updated_at BEFORE UPDATE ON course_offering
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
