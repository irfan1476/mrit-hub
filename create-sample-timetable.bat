@echo off
REM Create sample timetable data for testing

echo ========================================
echo 📅 Creating Sample Timetable Data
echo ========================================
echo.

echo Creating course offerings and timetable for testing...
docker exec -i mrit-postgres psql -U mrit_admin -d mrit_hub < database\create-sample-timetable.sql

echo.
echo 📊 Verifying created data...
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "SELECT 'Course Offerings' as entity, COUNT(*) FROM course_offering UNION ALL SELECT 'Timetable Entries', COUNT(*) FROM timetable;"

echo.
echo Sample timetable for today:
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "SELECT t.id, ts.slot_name, ts.start_time, ts.end_time, c.course_name, f.faculty_name, t.room_number FROM timetable t JOIN course_offering co ON t.course_offering_id = co.id JOIN course c ON co.course_id = c.id JOIN faculty f ON co.faculty_id = f.id JOIN time_slot ts ON t.time_slot_id = ts.id WHERE t.day_of_week = EXTRACT(ISODOW FROM CURRENT_DATE) AND t.active = true ORDER BY ts.start_time LIMIT 10;"

echo.
echo ✅ Sample timetable created!
echo.

pause
