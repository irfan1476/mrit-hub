#!/bin/bash

# MRIT Data Import Script
# This script imports all data from mrit.sql dump into the new schema

echo "🔄 Starting comprehensive MRIT data import..."
echo "=============================================="

# Step 1: Extract student_data from dump and transform to new schema
echo "📊 Step 1: Extracting and transforming student data..."

docker exec mrit-postgres psql -U mrit_admin -d mrit_hub << 'EOF'

-- Temporarily disable foreign key constraints for bulk import
SET session_replication_role = replica;

-- Clear existing data (except what we manually added)
DELETE FROM student_variables WHERE usn NOT IN (SELECT usn FROM student_data WHERE id <= 30);
DELETE FROM student_data WHERE id > 30;

-- Import will be done via COPY from the dump file
-- For now, let's prepare the structure

SET session_replication_role = DEFAULT;

\echo 'Student data structure prepared'
EOF

# Step 2: Extract student data from mrit.sql and import
echo "📥 Step 2: Extracting student records from dump..."

# Extract INSERT statements for student_data from the dump
grep -A 1000000 "COPY public.student_data" database/mrit.sql | \
  grep -B 5 "^\\\\\\." | \
  head -n -1 > /tmp/student_data_extract.txt

# Count how many students we're importing
STUDENT_COUNT=$(wc -l < /tmp/student_data_extract.txt)
echo "Found $STUDENT_COUNT student records to import"

# Step 3: Transform and import student data
echo "🔄 Step 3: Transforming and importing student data..."

# Create a transformation script
cat > /tmp/import_students.sql << 'EOSQL'
-- Disable constraints temporarily
SET session_replication_role = replica;

-- Create temporary table with old schema
CREATE TEMP TABLE temp_student_data (
    id integer,
    usn varchar(12),
    student_name varchar(50),
    branch_id integer,
    phone varchar(20),
    email varchar(50),
    email_org varchar(100),
    dob date,
    aadhar varchar(16),
    father_name varchar(50),
    father_phone varchar(30),
    mother_name varchar(50),
    alt_phone varchar(30),
    address varchar(500),
    blood_group varchar(5),
    gender_id integer,
    batch_id integer,
    entry_id integer,
    res_cat_id integer,
    adm_cat_id integer,
    sslc_percent numeric,
    sslc_board integer,
    puc_percent numeric,
    puc_board integer,
    year_back boolean,
    active boolean,
    grad_year_id integer,
    cur_scheme_id integer,
    cur_semester_id integer,
    cur_aca_yr integer,
    mentor_id integer,
    guide_id integer,
    scholarship_id varchar(20),
    sec_name varchar(10)
);

-- Copy data from dump (will be done separately)
-- \copy temp_student_data from '/tmp/student_data_extract.txt'

-- Transform and insert into new schema
INSERT INTO student_data (
    usn, student_name, branch_id, phone, email, dob,
    father_name, father_phone, mother_name, alt_phone,
    parent_primary_phone, address, blood_group, profile_photo_path,
    phone_verified, gender_id, batch_id, entry_id, res_cat_id, adm_cat_id
)
SELECT 
    usn, student_name, branch_id, phone, 
    COALESCE(email_org, email) as email, dob,
    father_name, father_phone, mother_name, alt_phone,
    COALESCE(father_phone, alt_phone) as parent_primary_phone,
    address, blood_group, NULL as profile_photo_path,
    false as phone_verified,
    gender_id, batch_id, entry_id, res_cat_id, adm_cat_id
FROM temp_student_data
WHERE usn IS NOT NULL
ON CONFLICT (usn) DO UPDATE SET
    student_name = EXCLUDED.student_name,
    phone = EXCLUDED.phone,
    email = EXCLUDED.email;

-- Insert into student_variables
INSERT INTO student_variables (
    usn, grad_year_id, scheme_id, semester_id, section_id,
    mentor_id, year_back, active
)
SELECT 
    usn, grad_year_id, cur_scheme_id, cur_semester_id,
    (SELECT id FROM section WHERE name = sec_name LIMIT 1) as section_id,
    mentor_id, year_back, active
FROM temp_student_data
WHERE usn IS NOT NULL
ON CONFLICT (usn) DO UPDATE SET
    semester_id = EXCLUDED.semester_id,
    section_id = EXCLUDED.section_id,
    active = EXCLUDED.active;

-- Re-enable constraints
SET session_replication_role = DEFAULT;

\echo 'Student data transformation complete'
EOSQL

echo "✅ Import script created"

# Step 4: Show current status
echo ""
echo "📊 Current Database Status:"
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "
SELECT 
    'Students' as entity, COUNT(*) as count FROM student_data
UNION ALL
SELECT 'Faculty', COUNT(*) FROM faculty
UNION ALL
SELECT 'Courses', COUNT(*) FROM course
UNION ALL
SELECT 'Time Slots', COUNT(*) FROM time_slot;
"

echo ""
echo "⚠️  IMPORTANT: Full data import requires:"
echo "1. Schema alignment between old and new structure"
echo "2. Handling of NULL values and missing foreign keys"
echo "3. Data transformation for changed column names"
echo ""
echo "📋 Next Steps:"
echo "1. Review schema differences in database/mrit.sql"
echo "2. Create field mapping for all tables"
echo "3. Run incremental imports with error handling"
echo ""
echo "🔧 For now, we have 30 students imported for testing"
echo "   To import ALL data, we need to:"
echo "   - Map old 'sec_name' to new 'section_id'"
echo "   - Handle 'cur_scheme_id' -> 'scheme_id' in student_variables"
echo "   - Transform employee_data -> faculty table"
echo "   - Import course data with proper mappings"

EOF

chmod +x /tmp/import_students.sql

echo ""
echo "✅ Import preparation complete!"
echo "📁 Files created:"
echo "   - /tmp/import_students.sql (transformation script)"
echo "   - /tmp/student_data_extract.txt (extracted data)"
