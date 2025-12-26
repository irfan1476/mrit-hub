@echo off
echo Checking all timetable tables for data...
echo.

echo time_table.tt_2425:
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "SELECT COUNT(*) FROM time_table.tt_2425;"

echo time_table.tt_2223:
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "SELECT COUNT(*) FROM time_table.tt_2223;"

echo time_table.timetable:
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "SELECT COUNT(*) FROM time_table.timetable;"

echo time_table.time_table_2122:
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "SELECT COUNT(*) FROM time_table.time_table_2122;"

echo time_table.course_alottment:
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "SELECT COUNT(*) FROM time_table.course_alottment;"

echo.
echo Checking which table has data...
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "SELECT 'tt_2425' as table_name, COUNT(*) FROM time_table.tt_2425 UNION ALL SELECT 'tt_2223', COUNT(*) FROM time_table.tt_2223 UNION ALL SELECT 'timetable', COUNT(*) FROM time_table.timetable UNION ALL SELECT 'time_table_2122', COUNT(*) FROM time_table.time_table_2122 UNION ALL SELECT 'course_alottment', COUNT(*) FROM time_table.course_alottment;"

echo.
echo Sample from tt_2223 (if it has data):
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "SELECT * FROM time_table.tt_2223 LIMIT 3;"

pause
