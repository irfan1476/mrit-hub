@echo off
REM Check imported data structure and import correctly

echo Checking imported table structure...
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "\d public.student_data"

echo.
echo Checking sample data...
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "SELECT usn, student_name, email, email_org, grad_year_id, cur_scheme_id FROM public.student_data LIMIT 3;"

echo.
echo Checking course table structure...
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "\d course"

echo.
echo Checking public.course data...
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "SELECT * FROM public.course LIMIT 3;"

pause
