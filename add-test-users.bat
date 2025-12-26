@echo off
echo ========================================
echo Adding Test Users to Database
echo ========================================
echo.

docker exec -i mrit-postgres psql -U mrit_admin -d mrit_hub < database\add-test-users.sql

echo.
echo Test users added!
echo.
echo Login credentials:
echo   Email: faculty@mysururoyal.org
echo   Password: password123
echo.
pause
