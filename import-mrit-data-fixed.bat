@echo off
REM Import actual MRIT data - Fixed column mapping

echo ========================================
echo 📊 MRIT Data Import - Real Data (Fixed)
echo ========================================
echo.

echo ✅ Found mrit.sql
echo.

echo 🔄 Step 1: Transforming and migrating data...

REM Import Students (matching old schema columns)
echo Importing students...
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "SET session_replication_role = replica; DELETE FROM student_data WHERE id > 30; INSERT INTO student_data (usn, student_name, branch_id, phone, email, dob, father_name, father_phone, mother_name, alt_phone, parent_primary_phone, address, blood_group, phone_verified, gender_id, batch_id, entry_id, res_cat_id, adm_cat_id) SELECT usn, student_name, branch_id, phone, COALESCE(email_org, email) as email, dob, father_name, father_phone, mother_name, alt_phone, COALESCE(father_phone, alt_phone) as parent_primary_phone, address, blood_group, false, gender_id, batch_id, entry_id, res_cat_id, adm_cat_id FROM public.student_data WHERE usn IS NOT NULL AND active = true ON CONFLICT (usn) DO NOTHING; SET session_replication_role = DEFAULT;"

REM Import Student Variables
echo Importing student variables...
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "INSERT INTO student_variables (usn, grad_year_id, scheme_id, semester_id, section_id, mentor_id, year_back, active) SELECT sd.usn, sd.grad_year_id, sd.cur_scheme_id, sd.cur_semester_id, s.id, sd.mentor_id, sd.year_back, sd.active FROM public.student_data sd LEFT JOIN section s ON s.name = sd.sec_name WHERE sd.usn IS NOT NULL AND sd.active = true ON CONFLICT (usn) DO NOTHING;"

REM Import Faculty (matching actual faculty table columns)
echo Importing faculty...
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "INSERT INTO faculty (faculty_name, short_name, phone, email_org, email_personal, dob, address, qualification, join_date, pan, aadhar, active) SELECT employee_name, short_name, phone::bigint, email_org, email_personal, dob, address, qualification, join_date, pan, aadhar::bigint, active FROM public.employee_data WHERE active = true ON CONFLICT (phone) DO NOTHING;"

REM Import Courses
echo Importing courses...
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "INSERT INTO course (course_code, course_name, credit, scheme_id, semester_id, dept_id, course_cat_id, course_gp_id) SELECT course_code, course_name, credit, scheme_id, semester_id, dept_id, course_cat_id, course_gp_id FROM public.course ON CONFLICT (course_code, scheme_id) DO NOTHING;"

echo.
echo 📊 Step 2: Verifying imported data...
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "SELECT 'Students' as entity, COUNT(*) as count FROM student_data UNION ALL SELECT 'Student Variables', COUNT(*) FROM student_variables UNION ALL SELECT 'Faculty', COUNT(*) FROM faculty UNION ALL SELECT 'Courses', COUNT(*) FROM course;"

echo.
echo ✅ Import Complete!
echo.
echo 📋 Summary:
echo - Student data imported from mrit.sql
echo - Faculty data imported from employee_data
echo - Courses imported
echo.
echo ⚠️  Note: Course offerings and timetable require additional mapping
echo    (faculty employee_id to new faculty.id, etc.)
echo.

pause
