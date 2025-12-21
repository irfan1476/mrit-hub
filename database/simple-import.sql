-- Simplified MRIT Data Import Script
-- Import key data from existing mrit.sql tables

-- ============================================================================
-- IMPORT FACULTY DATA
-- ============================================================================

-- Import faculty from employee_data table
INSERT INTO faculty (
    employee_id,
    faculty_name,
    short_name,
    email_org,
    email_personal,
    dob,
    address,
    qualification,
    join_date,
    pan,
    aadhar,
    active
)
SELECT 
    employee_id,
    employee_name,
    short_name,
    email_org,
    email_personal,
    dob,
    LEFT(address, 200),
    LEFT(qualification, 10),
    join_date,
    pan,
    aadhar,
    COALESCE(active, true)
FROM employee_data
WHERE employee_name IS NOT NULL
    AND employee_id IS NOT NULL
ON CONFLICT (employee_id) DO UPDATE SET
    faculty_name = EXCLUDED.faculty_name,
    email_org = EXCLUDED.email_org,
    active = EXCLUDED.active;

-- ============================================================================
-- IMPORT STUDENT DATA
-- ============================================================================

-- Import students from student_data table
INSERT INTO student_data (
    usn,
    student_name,
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
    sec_name
)
SELECT 
    s.usn,
    s.student_name,
    CASE 
        WHEN LENGTH(s.phone) <= 12 THEN s.phone
        ELSE LEFT(s.phone, 12)
    END as phone,
    s.email,
    s.dob,
    s.father_name,
    CASE 
        WHEN LENGTH(s.father_phone) <= 12 THEN s.father_phone
        ELSE LEFT(s.father_phone, 12)
    END as father_phone,
    s.mother_name,
    CASE 
        WHEN LENGTH(s.alt_phone) <= 12 THEN s.alt_phone
        ELSE LEFT(s.alt_phone, 12)
    END as alt_phone,
    CASE 
        WHEN LENGTH(COALESCE(s.father_phone, s.alt_phone)) <= 12 THEN COALESCE(s.father_phone, s.alt_phone)
        ELSE LEFT(COALESCE(s.father_phone, s.alt_phone), 12)
    END as parent_primary_phone,
    LEFT(s.address, 200),
    s.blood_group,
    CASE 
        WHEN s.gender_id BETWEEN 1 AND 3 THEN s.gender_id 
        ELSE 1 
    END as gender_id,
    CASE 
        WHEN s.batch_id BETWEEN 1 AND 10 THEN s.batch_id 
        ELSE 1 
    END as batch_id,
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
    LEFT(s.sec_name, 5)
FROM student_data s
WHERE s.usn IS NOT NULL 
    AND LENGTH(s.usn) >= 4
    AND s.student_name IS NOT NULL
ON CONFLICT (usn) DO UPDATE SET
    student_name = EXCLUDED.student_name,
    phone = EXCLUDED.phone,
    email = EXCLUDED.email,
    sec_name = EXCLUDED.sec_name;

-- ============================================================================
-- IMPORT COURSE DATA
-- ============================================================================

-- Import courses from courses.scheme table
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
FROM courses.scheme
WHERE "Course Code" IS NOT NULL 
    AND "Course Name" IS NOT NULL
ON CONFLICT (course_code) DO UPDATE SET
    course_name = EXCLUDED.course_name,
    credits = EXCLUDED.credits,
    scheme_year = EXCLUDED.scheme_year;

-- ============================================================================
-- IMPORT SUMMARY
-- ============================================================================

-- Generate import summary
SELECT 
    'Faculty Imported' as table_name,
    COUNT(*) as count
FROM faculty
WHERE employee_id IS NOT NULL

UNION ALL

SELECT 
    'Students Imported' as table_name,
    COUNT(*) as count
FROM student_data

UNION ALL

SELECT 
    'Courses Imported' as table_name,
    COUNT(*) as count
FROM course

UNION ALL

SELECT 
    'Total Records' as table_name,
    (SELECT COUNT(*) FROM faculty WHERE employee_id IS NOT NULL) +
    (SELECT COUNT(*) FROM student_data) +
    (SELECT COUNT(*) FROM course) as count;