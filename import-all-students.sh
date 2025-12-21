#!/bin/bash

echo "🚀 MRIT Full Data Import"
echo "========================"

# Extract student data from dump
echo "📊 Step 1: Extracting student data from mrit.sql..."
sed -n '207572,/^\\\\\.$/p' database/mrit.sql | sed '$d' > /tmp/student_data_raw.tsv
STUDENT_COUNT=$(wc -l < /tmp/student_data_raw.tsv)
echo "   Found $STUDENT_COUNT student records"

# Extract employee/faculty data
echo "👨🏫 Step 2: Extracting faculty data..."
EMPLOYEE_LINE=$(grep -n "COPY public.employee_data" database/mrit.sql | cut -d: -f1)
if [ ! -z "$EMPLOYEE_LINE" ]; then
    EMPLOYEE_LINE=$((EMPLOYEE_LINE + 1))
    sed -n "${EMPLOYEE_LINE},/^\\\\\.$/p" database/mrit.sql | sed '$d' > /tmp/employee_data_raw.tsv
    FACULTY_COUNT=$(wc -l < /tmp/employee_data_raw.tsv)
    echo "   Found $FACULTY_COUNT faculty records"
fi

# Extract course data
echo "📚 Step 3: Extracting course data..."
COURSE_LINE=$(grep -n "COPY public.course" database/mrit.sql | head -1 | cut -d: -f1)
if [ ! -z "$COURSE_LINE" ]; then
    COURSE_LINE=$((COURSE_LINE + 1))
    sed -n "${COURSE_LINE},/^\\\\\.$/p" database/mrit.sql | sed '$d' > /tmp/course_data_raw.tsv
    COURSE_COUNT=$(wc -l < /tmp/course_data_raw.tsv)
    echo "   Found $COURSE_COUNT course records"
fi

# Import into database
echo ""
echo "💾 Step 4: Importing data into database..."

docker cp /tmp/student_data_raw.tsv mrit-postgres:/tmp/
docker cp /tmp/employee_data_raw.tsv mrit-postgres:/tmp/
docker cp /tmp/course_data_raw.tsv mrit-postgres:/tmp/

docker exec mrit-postgres psql -U mrit_admin -d mrit_hub << 'EOSQL'

-- Disable constraints
SET session_replication_role = replica;

-- Create temp table for student data
CREATE TEMP TABLE temp_students (
    id integer, usn varchar(12), student_name varchar(50), branch_id integer,
    phone varchar(20), email varchar(50), email_org varchar(100), dob date,
    aadhar varchar(16), father_name varchar(50), father_phone varchar(30),
    mother_name varchar(50), alt_phone varchar(30), address varchar(500),
    blood_group varchar(5), gender_id integer, batch_id integer, entry_id integer,
    res_cat_id integer, adm_cat_id integer, sslc_percent numeric, sslc_board integer,
    puc_percent numeric, puc_board integer, year_back boolean, active boolean,
    grad_year_id integer, cur_scheme_id integer, cur_semester_id integer,
    cur_aca_yr integer, mentor_id integer, guide_id integer,
    scholarship_id varchar(20), sec_name varchar(10)
);

-- Import student data
\copy temp_students FROM '/tmp/student_data_raw.tsv' WITH (FORMAT text, DELIMITER E'\t', NULL '\\N');

-- Transform and insert students
INSERT INTO student_data (
    usn, student_name, branch_id, phone, email, dob,
    father_name, father_phone, mother_name, alt_phone,
    parent_primary_phone, address, blood_group,
    gender_id, batch_id, entry_id, res_cat_id, adm_cat_id
)
SELECT 
    usn, student_name, branch_id, phone,
    COALESCE(email_org, email), dob,
    father_name, father_phone, mother_name, alt_phone,
    COALESCE(father_phone, alt_phone), address, blood_group,
    gender_id, batch_id, entry_id, res_cat_id, adm_cat_id
FROM temp_students
WHERE usn IS NOT NULL AND usn != ''
ON CONFLICT (usn) DO UPDATE SET
    student_name = EXCLUDED.student_name,
    phone = EXCLUDED.phone,
    email = EXCLUDED.email,
    branch_id = EXCLUDED.branch_id;

-- Insert student variables
INSERT INTO student_variables (
    usn, grad_year_id, scheme_id, semester_id, section_id,
    mentor_id, year_back, active
)
SELECT 
    usn, grad_year_id, cur_scheme_id, cur_semester_id,
    CASE 
        WHEN sec_name = 'A' THEN 1
        WHEN sec_name = 'B' THEN 2
        WHEN sec_name = 'C' THEN 3
        WHEN sec_name = 'D' THEN 4
        ELSE NULL
    END as section_id,
    mentor_id, year_back, active
FROM temp_students
WHERE usn IS NOT NULL AND usn != ''
ON CONFLICT (usn) DO UPDATE SET
    semester_id = EXCLUDED.semester_id,
    section_id = EXCLUDED.section_id,
    scheme_id = EXCLUDED.scheme_id,
    active = EXCLUDED.active;

-- Re-enable constraints
SET session_replication_role = DEFAULT;

-- Show results
SELECT 
    'Students Imported' as status,
    COUNT(*) as count
FROM student_data;

SELECT 
    'Student Variables' as status,
    COUNT(*) as count
FROM student_variables;

EOSQL

echo ""
echo "✅ Import Complete!"
echo ""
echo "📊 Final Database Status:"
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "
SELECT 
    'Students' as entity, COUNT(*) as count FROM student_data
UNION ALL
SELECT 'Faculty', COUNT(*) FROM faculty
UNION ALL
SELECT 'Courses', COUNT(*) FROM course
UNION ALL
SELECT 'Student Variables', COUNT(*) FROM student_variables;
"

echo ""
echo "🎓 Sample Students by Department:"
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "
SELECT 
    d.code as dept,
    COUNT(*) as students
FROM student_data sd
JOIN department d ON sd.branch_id = d.id
GROUP BY d.code
ORDER BY students DESC
LIMIT 10;
"
