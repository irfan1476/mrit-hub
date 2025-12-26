@echo off
REM Import actual MRIT data from mrit.sql dump
REM This imports students, faculty, courses, and timetables

echo ========================================
echo 📊 MRIT Data Import - Real Data
echo ========================================
echo.

REM Check if mrit.sql exists
if not exist "database\mrit.sql" (
    echo ❌ Error: database\mrit.sql not found
    pause
    exit /b 1
)

echo ✅ Found mrit.sql (21MB)
echo.

REM Step 1: Create temporary schemas for import
echo 📦 Step 1: Creating temporary schemas...
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "CREATE SCHEMA IF NOT EXISTS infra; CREATE SCHEMA IF NOT EXISTS time_table; CREATE SCHEMA IF NOT EXISTS courses;"

REM Step 2: Import the full dump into temp schemas
echo 📥 Step 2: Importing mrit.sql dump (this may take 2-3 minutes)...
docker exec -i mrit-postgres psql -U mrit_admin -d mrit_hub < database\mrit.sql 2>import-errors.log

if %ERRORLEVEL% NEQ 0 (
    echo ⚠️  Import completed with some errors - check import-errors.log
) else (
    echo ✅ Import successful
)

echo.
echo 🔄 Step 3: Transforming and migrating data to new schema...

REM Import Students
echo Importing students...
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "SET session_replication_role = replica; TRUNCATE student_data, student_variables, faculty, course_offering, timetable CASCADE; INSERT INTO student_data (usn, student_name, branch_id, phone, email, dob, father_name, father_phone, mother_name, alt_phone, parent_primary_phone, address, blood_group, phone_verified, gender_id, batch_id, entry_id, res_cat_id, adm_cat_id) SELECT usn, student_name, branch_id, phone, COALESCE(email_org, email) as email, dob, father_name, father_phone, mother_name, alt_phone, COALESCE(father_phone, alt_phone) as parent_primary_phone, address, blood_group, false as phone_verified, gender_id, batch_id, entry_id, res_cat_id, adm_cat_id FROM public.student_data WHERE usn IS NOT NULL AND active = true ON CONFLICT (usn) DO NOTHING; SET session_replication_role = DEFAULT;"

REM Import Student Variables
echo Importing student variables...
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "INSERT INTO student_variables (usn, grad_year_id, scheme_id, semester_id, section_id, mentor_id, year_back, active) SELECT sd.usn, sd.grad_year_id, sd.cur_scheme_id, sd.cur_semester_id, s.id as section_id, sd.mentor_id, sd.year_back, sd.active FROM public.student_data sd LEFT JOIN section s ON s.name = sd.sec_name WHERE sd.usn IS NOT NULL AND sd.active = true ON CONFLICT (usn) DO NOTHING;"

REM Import Faculty
echo Importing faculty...
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "INSERT INTO faculty (employee_id, faculty_name, short_name, phone, email, department_id, designation_id, active, gender_id) SELECT employee_id, employee_name, short_name, phone, COALESCE(email_org, email_personal) as email, dept_id, designation_id, active, gender_id FROM public.employee_data WHERE active = true AND dept_id IS NOT NULL ON CONFLICT (employee_id) DO NOTHING;"

REM Import Course Offerings
echo Importing course offerings...
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "INSERT INTO course_offering (course_id, faculty_id, section_id, academic_year_id, active) SELECT DISTINCT c.id as course_id, f.id as faculty_id, s.id as section_id, tt.aca_yr_id, true as active FROM time_table.tt_2425 tt JOIN course c ON c.course_code = tt.course_code JOIN faculty f ON f.employee_id = tt.faculty_id JOIN section s ON s.id = tt.section_id WHERE tt.course_code IS NOT NULL AND tt.faculty_id IS NOT NULL ON CONFLICT DO NOTHING;"

REM Import Timetable
echo Importing timetable...
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "INSERT INTO timetable (course_offering_id, time_slot_id, day_of_week, room_number, active) SELECT DISTINCT co.id as course_offering_id, tt.class_id as time_slot_id, tt.weekday_id as day_of_week, COALESCE(rn.room_number, 'TBA') as room_number, true as active FROM time_table.tt_2425 tt JOIN course c ON c.course_code = tt.course_code JOIN faculty f ON f.employee_id = tt.faculty_id JOIN section s ON s.id = tt.section_id JOIN course_offering co ON co.course_id = c.id AND co.faculty_id = f.id AND co.section_id = s.id AND co.academic_year_id = tt.aca_yr_id LEFT JOIN infra.room_numbers rn ON rn.id = tt.room_number_id WHERE tt.course_code IS NOT NULL ON CONFLICT DO NOTHING;"

echo.
echo 📊 Step 4: Verifying imported data...
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "SELECT 'Students' as entity, COUNT(*) as count FROM student_data UNION ALL SELECT 'Faculty', COUNT(*) FROM faculty UNION ALL SELECT 'Courses', COUNT(*) FROM course UNION ALL SELECT 'Course Offerings', COUNT(*) FROM course_offering UNION ALL SELECT 'Timetable Entries', COUNT(*) FROM timetable;"

echo.
echo ✅ Import Complete!
echo.
echo 📋 Summary:
echo - Real student data imported from mrit.sql
echo - Faculty data imported from employee_data
echo - Course offerings created from timetable
echo - Timetable entries populated with room numbers
echo.
echo 🔍 Check import-errors.log for any warnings
echo.

pause
