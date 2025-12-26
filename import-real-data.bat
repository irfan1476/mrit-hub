@echo off
REM Import MRIT data - Working version with correct columns

echo ========================================
echo 📊 MRIT Data Import - Working Version
echo ========================================
echo.

echo 🔄 Importing data from mrit.sql schemas...
echo.

REM Import Students from the OLD public.student_data (before it was modified)
REM The mrit.sql has the original table, but it was overwritten by migrations
echo Importing students from time_table.section_alott...
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "INSERT INTO student_variables (usn, scheme_id, semester_id, section_id, active) SELECT DISTINCT sa.usn, sa.scheme_id, sa.semester_id, sa.sec_name_id, true FROM time_table.section_alott sa WHERE sa.usn IS NOT NULL AND sa.usn IN (SELECT usn FROM student_data) ON CONFLICT (usn) DO UPDATE SET scheme_id = EXCLUDED.scheme_id, semester_id = EXCLUDED.semester_id, section_id = EXCLUDED.section_id;"

REM Import Courses from courses.scheme
echo Importing courses from courses.scheme...
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "INSERT INTO course (course_code, course_name, branch, semester, lecture_hours, tutorial_hours, practical_hours, cie_marks, see_marks, credits, scheme_year) SELECT DISTINCT \"Course Code\", \"Course Name\", \"Branch\", \"Semester\", \"Lecture (L)\", \"Tutorial (T)\", \"Practical (P)\", \"CIE Marks\", \"SEE Marks\", \"Credits\", scheme_year FROM courses.scheme WHERE \"Course Code\" IS NOT NULL ON CONFLICT (course_code) DO NOTHING;"

REM Import Course Offerings from time_table.course_alottment
echo Importing course offerings from time_table.course_alottment...
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "INSERT INTO course_offering (course_id, faculty_id, section_id, academic_year_id, active) SELECT DISTINCT c.id, ca.faculty_id, ca.sec_name AS section_id, ca.aca_yr_id, true FROM time_table.course_alottment ca JOIN course c ON c.id = ca.course_id WHERE ca.faculty_id IS NOT NULL AND ca.course_id IS NOT NULL AND ca.faculty_id <= (SELECT MAX(id) FROM faculty) ON CONFLICT DO NOTHING;"

REM Import Timetable from time_table.tt_2425
echo Importing timetable from time_table.tt_2425...
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "INSERT INTO timetable (course_offering_id, time_slot_id, day_of_week, room_number, active) SELECT DISTINCT co.id, tt.class_id, tt.weekday_id, COALESCE(rn.room_number, 'TBA'), true FROM time_table.tt_2425 tt JOIN course c ON c.course_code = tt.course_code JOIN course_offering co ON co.course_id = c.id AND co.academic_year_id = tt.aca_yr_id AND co.section_id = tt.section_id LEFT JOIN infra.room_numbers rn ON rn.id = tt.room_number_id WHERE tt.class_id BETWEEN 1 AND 15 AND tt.weekday_id BETWEEN 1 AND 7 ON CONFLICT DO NOTHING;"

echo.
echo 📊 Verifying imported data...
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "SELECT 'Students' as entity, COUNT(*) as count FROM student_data UNION ALL SELECT 'Student Variables', COUNT(*) FROM student_variables UNION ALL SELECT 'Faculty', COUNT(*) FROM faculty UNION ALL SELECT 'Courses', COUNT(*) FROM course UNION ALL SELECT 'Course Offerings', COUNT(*) FROM course_offering UNION ALL SELECT 'Timetable Entries', COUNT(*) FROM timetable;"

echo.
echo ✅ Import Complete!
echo.

pause
