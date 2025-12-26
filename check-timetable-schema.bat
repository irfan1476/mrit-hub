@echo off
echo Checking time_table.section_alott structure...
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "\d time_table.section_alott"

echo.
echo Checking time_table.course_alottment structure...
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "\d time_table.course_alottment"

echo.
echo Sample course_alottment data...
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "SELECT * FROM time_table.course_alottment LIMIT 3;"

echo.
echo Checking time_table.tt_2425 structure...
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "\d time_table.tt_2425"

echo.
echo Sample tt_2425 data...
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "SELECT * FROM time_table.tt_2425 LIMIT 3;"

pause
