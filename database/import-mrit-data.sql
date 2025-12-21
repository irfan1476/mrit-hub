-- MRIT Data Import Script
-- Import high-priority data from mrit.sql to MRIT Hub

-- ============================================================================
-- PHASE 1: REFERENCE DATA IMPORT
-- ============================================================================

-- Import departments (map mrit.sql departments to our schema)
INSERT INTO department (code, dept_name) 
SELECT DISTINCT 
    CASE 
        WHEN dept_name LIKE '%Computer%' THEN 'CSE'
        WHEN dept_name LIKE '%Electronics%' AND dept_name LIKE '%Communication%' THEN 'ECE'
        WHEN dept_name LIKE '%Mechanical%' THEN 'ME'
        WHEN dept_name LIKE '%Civil%' THEN 'CV'
        WHEN dept_name LIKE '%Electrical%' THEN 'EEE'
        WHEN dept_name LIKE '%Information%' THEN 'ISE'
        WHEN dept_name LIKE '%Chemistry%' THEN 'CHE'
        WHEN dept_name LIKE '%Physics%' THEN 'PHY'
        WHEN dept_name LIKE '%Mathematics%' THEN 'MAT'
        WHEN dept_name LIKE '%Humanities%' THEN 'HSM'
        ELSE LEFT(UPPER(REPLACE(dept_name, ' ', '')), 5)
    END as code,
    dept_name
FROM mrit_external.department 
WHERE dept_name IS NOT NULL
ON CONFLICT (code) DO NOTHING;

-- Create department mapping table for ID translation
CREATE TEMP TABLE dept_mapping AS
SELECT 
    m.id as mrit_id,
    h.id as hub_id,
    m.dept_name
FROM mrit_external.department m
JOIN department h ON (
    (m.dept_name LIKE '%Computer%' AND h.code = 'CSE') OR
    (m.dept_name LIKE '%Electronics%' AND m.dept_name LIKE '%Communication%' AND h.code = 'ECE') OR
    (m.dept_name LIKE '%Mechanical%' AND h.code = 'ME') OR
    (m.dept_name LIKE '%Civil%' AND h.code = 'CV') OR
    (m.dept_name LIKE '%Electrical%' AND h.code = 'EEE') OR
    (m.dept_name LIKE '%Information%' AND h.code = 'ISE') OR
    (m.dept_name LIKE '%Chemistry%' AND h.code = 'CHE') OR
    (m.dept_name LIKE '%Physics%' AND h.code = 'PHY') OR
    (m.dept_name LIKE '%Mathematics%' AND h.code = 'MAT') OR
    (m.dept_name LIKE '%Humanities%' AND h.code = 'HSM')
);

-- ============================================================================
-- PHASE 2: FACULTY DATA IMPORT
-- ============================================================================

INSERT INTO faculty (
    employee_id,
    faculty_name,
    phone,
    short_name,
    email_org,
    email_personal,
    dob,
    address,
    qualification,
    join_date,
    pan,
    aadhar,
    dept_id,
    active
)
SELECT 
    e.employee_id,
    e.employee_name,
    CASE 
        WHEN LENGTH(e.phone::text) <= 12 THEN e.phone::text
        ELSE NULL 
    END as phone,
    e.short_name,
    e.email_org,
    e.email_personal,
    e.dob,
    LEFT(e.address, 200),
    LEFT(e.qualification, 10),
    e.join_date,
    e.pan,
    e.aadhar,
    dm.hub_id as dept_id,
    COALESCE(e.active, true)
FROM mrit_external.employee_data e
LEFT JOIN dept_mapping dm ON e.dept_id = dm.mrit_id
WHERE e.employee_name IS NOT NULL
ON CONFLICT (employee_id) DO UPDATE SET
    faculty_name = EXCLUDED.faculty_name,
    phone = EXCLUDED.phone,
    email_org = EXCLUDED.email_org,
    dept_id = EXCLUDED.dept_id,
    active = EXCLUDED.active;

-- ============================================================================
-- PHASE 3: STUDENT DATA IMPORT
-- ============================================================================

-- Import batch years from student data
INSERT INTO batch (year)
SELECT DISTINCT 
    CASE 
        WHEN LENGTH(usn) >= 4 THEN 
            2000 + CAST(SUBSTRING(usn, 1, 2) AS INTEGER)
        ELSE NULL
    END as batch_year
FROM mrit_external.student_data 
WHERE usn IS NOT NULL 
    AND LENGTH(usn) >= 4 
    AND SUBSTRING(usn, 1, 2) ~ '^[0-9]+$'
    AND CAST(SUBSTRING(usn, 1, 2) AS INTEGER) BETWEEN 15 AND 30
ON CONFLICT (year) DO NOTHING;

-- Import graduation years
INSERT INTO grad_year (year)
SELECT DISTINCT 
    CASE 
        WHEN LENGTH(usn) >= 4 THEN 
            2000 + CAST(SUBSTRING(usn, 1, 2) AS INTEGER) + 4
        ELSE NULL
    END as grad_year
FROM mrit_external.student_data 
WHERE usn IS NOT NULL 
    AND LENGTH(usn) >= 4 
    AND SUBSTRING(usn, 1, 2) ~ '^[0-9]+$'
    AND CAST(SUBSTRING(usn, 1, 2) AS INTEGER) BETWEEN 15 AND 30
ON CONFLICT (year) DO NOTHING;

-- Create batch mapping
CREATE TEMP TABLE batch_mapping AS
SELECT 
    2000 + CAST(SUBSTRING(s.usn, 1, 2) AS INTEGER) as batch_year,
    b.id as batch_id
FROM mrit_external.student_data s
JOIN batch b ON b.year = 2000 + CAST(SUBSTRING(s.usn, 1, 2) AS INTEGER)
WHERE LENGTH(s.usn) >= 4 
    AND SUBSTRING(s.usn, 1, 2) ~ '^[0-9]+$'
GROUP BY batch_year, b.id;

-- Import student data
INSERT INTO student_data (
    usn,
    student_name,
    branch_id,
    phone,
    email,
    dob,
    father_name,
    father_phone,
    mother_name,
    alt_phone,
    parent_primary_phone,
    address,
    blood_group,
    gender_id,
    batch_id,
    entry_id,
    res_cat_id,
    adm_cat_id,
    sec_name,
    cur_semester_id,
    cur_aca_yr,
    cur_scheme_id
)
SELECT 
    s.usn,
    s.student_name,
    dm.hub_id as branch_id,
    LEFT(s.phone, 12),
    s.email,
    s.dob,
    s.father_name,
    LEFT(s.father_phone, 12),
    s.mother_name,
    LEFT(s.alt_phone, 12),
    LEFT(COALESCE(s.father_phone, s.alt_phone), 12) as parent_primary_phone,
    LEFT(s.address, 200),
    s.blood_group,
    CASE 
        WHEN s.gender_id BETWEEN 1 AND 3 THEN s.gender_id 
        ELSE 1 
    END as gender_id,
    bm.batch_id,
    CASE 
        WHEN s.entry_id BETWEEN 1 AND 2 THEN s.entry_id 
        ELSE 1 
    END as entry_id,
    CASE 
        WHEN s.res_cat_id BETWEEN 1 AND 5 THEN s.res_cat_id 
        ELSE 1 
    END as res_cat_id,
    CASE 
        WHEN s.adm_cat_id BETWEEN 1 AND 4 THEN s.adm_cat_id 
        ELSE 1 
    END as adm_cat_id,
    LEFT(s.sec_name, 5),
    CASE 
        WHEN s.cur_semester_id BETWEEN 1 AND 8 THEN s.cur_semester_id 
        ELSE NULL 
    END,
    s.cur_aca_yr,
    CASE 
        WHEN s.cur_scheme_id BETWEEN 1 AND 5 THEN s.cur_scheme_id 
        ELSE NULL 
    END
FROM mrit_external.student_data s
LEFT JOIN dept_mapping dm ON s.branch_id = dm.mrit_id
LEFT JOIN batch_mapping bm ON bm.batch_year = 2000 + CAST(SUBSTRING(s.usn, 1, 2) AS INTEGER)
WHERE s.usn IS NOT NULL 
    AND LENGTH(s.usn) >= 4
    AND s.student_name IS NOT NULL
ON CONFLICT (usn) DO UPDATE SET
    student_name = EXCLUDED.student_name,
    phone = EXCLUDED.phone,
    email = EXCLUDED.email,
    branch_id = EXCLUDED.branch_id,
    sec_name = EXCLUDED.sec_name;

-- ============================================================================
-- PHASE 4: COURSE DATA IMPORT
-- ============================================================================

INSERT INTO course (
    course_code,
    course_name,
    branch,
    semester,
    lecture_hours,
    tutorial_hours,
    practical_hours,
    cie_marks,
    see_marks,
    credits,
    scheme_year
)
SELECT 
    "Course Code",
    "Course Name",
    "Branch",
    "Semester",
    COALESCE("Lecture (L)", 0),
    COALESCE("Tutorial (T)", 0),
    COALESCE("Practical (P)", 0),
    COALESCE("CIE Marks", 50),
    COALESCE("SEE Marks", 50),
    COALESCE("Credits", 3),
    scheme_year
FROM mrit_external.courses_scheme
WHERE "Course Code" IS NOT NULL 
    AND "Course Name" IS NOT NULL
ON CONFLICT (course_code) DO UPDATE SET
    course_name = EXCLUDED.course_name,
    credits = EXCLUDED.credits,
    scheme_year = EXCLUDED.scheme_year;

-- ============================================================================
-- PHASE 5: MENTOR MAPPING IMPORT
-- ============================================================================

-- Update student mentor assignments
UPDATE student_variables sv
SET mentor_id = f.id
FROM mrit_external.mentor m
JOIN faculty f ON f.employee_id = m.mentor_id
WHERE sv.usn = m.usn
    AND f.id IS NOT NULL;

-- ============================================================================
-- IMPORT SUMMARY
-- ============================================================================

-- Generate import summary
SELECT 
    'Faculty' as table_name,
    COUNT(*) as imported_count
FROM faculty
WHERE employee_id IS NOT NULL

UNION ALL

SELECT 
    'Students' as table_name,
    COUNT(*) as imported_count
FROM student_data

UNION ALL

SELECT 
    'Courses' as table_name,
    COUNT(*) as imported_count
FROM course

UNION ALL

SELECT 
    'Departments' as table_name,
    COUNT(*) as imported_count
FROM department;

-- Clean up temp tables
DROP TABLE IF EXISTS dept_mapping;
DROP TABLE IF EXISTS batch_mapping;