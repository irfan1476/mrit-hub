@echo off
echo ========================================
echo MRIT Hub - Database Setup
echo ========================================
echo.

REM Check if postgres container is running
docker ps | findstr mrit-postgres >nul 2>&1
if errorlevel 1 (
    echo ERROR: mrit-postgres container is not running!
    echo Please run start.bat first.
    pause
    exit /b 1
)

echo Initializing database schema...
docker exec -i mrit-postgres psql -U mrit_admin -d mrit_hub < database\init\01-schema.sql

echo.
echo Loading seed data...
docker exec -i mrit-postgres psql -U mrit_admin -d mrit_hub < database\init\02-seed.sql

echo.
echo Running migrations...
for %%f in (database\migrations\*.sql) do (
    echo Running %%f...
    docker exec -i mrit-postgres psql -U mrit_admin -d mrit_hub < "%%f"
)

echo.
echo Database setup complete!
echo.
echo Verifying tables...
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "\dt"

echo.
pause
