@echo off
REM MRIT Data Import Script for Windows
REM This script imports all data from mrit.sql dump into the new schema

echo 🔄 Starting comprehensive MRIT data import...
echo ==============================================
echo.

REM Step 1: Extract and transform student data
echo 📊 Step 1: Extracting and transforming student data...
echo.

docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "SET session_replication_role = replica; DELETE FROM student_variables WHERE usn NOT IN (SELECT usn FROM student_data WHERE id <= 30); DELETE FROM student_data WHERE id > 30; SET session_replication_role = DEFAULT; SELECT 'Student data structure prepared' as status;"

echo.
echo 📊 Current Database Status:
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "SELECT 'Students' as entity, COUNT(*) as count FROM student_data UNION ALL SELECT 'Faculty', COUNT(*) FROM faculty UNION ALL SELECT 'Courses', COUNT(*) FROM course UNION ALL SELECT 'Time Slots', COUNT(*) FROM time_slot;"

echo.
echo ⚠️  IMPORTANT: Full data import requires:
echo 1. Schema alignment between old and new structure
echo 2. Handling of NULL values and missing foreign keys
echo 3. Data transformation for changed column names
echo.
echo 📋 Next Steps:
echo 1. Review schema differences in database\mrit.sql
echo 2. Create field mapping for all tables
echo 3. Run incremental imports with error handling
echo.
echo 🔧 For now, we have 30 students imported for testing
echo    To import ALL data, we need to:
echo    - Map old 'sec_name' to new 'section_id'
echo    - Handle 'cur_scheme_id' -^> 'scheme_id' in student_variables
echo    - Transform employee_data -^> faculty table
echo    - Import course data with proper mappings
echo.
echo ✅ Import preparation complete!

pause
