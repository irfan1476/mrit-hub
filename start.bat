@echo off
echo Starting MRIT Hub v1...
echo.

REM Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker is not running!
    echo Please start Docker Desktop and try again.
    pause
    exit /b 1
)

REM Check if .env exists
if not exist .env (
    echo .env file not found. Creating from template...
    copy .env.example .env
    echo Created .env file. Please edit it with your credentials.
    echo IMPORTANT: Ensure DATABASE_URL uses 'postgres' as hostname
    echo.
)

REM Start Docker services
echo Starting Docker services...
docker compose up -d

if errorlevel 1 (
    echo.
    echo ERROR: Failed to start services!
    echo Try running: docker compose down
    echo Then run start.bat again
    pause
    exit /b 1
)

echo.
echo Waiting for services to be healthy...
timeout /t 30 /nobreak >nul

REM Check service status
echo.
echo Service Status:
docker compose ps

echo.
echo MRIT Hub is starting!
echo.
echo Access points:
echo   - Frontend: http://localhost:8080
echo   - Backend API: http://localhost:3000
echo   - PostgreSQL: localhost:5432
echo   - Redis: localhost:6379
echo.
echo Login credentials:
echo   Email: faculty@mysururoyal.org
echo   Password: password123
echo.
echo To view logs:
echo   docker compose logs -f backend
echo.
echo To stop:
echo   docker compose down
echo.
echo Next step: Run deploy-frontend.bat to deploy UI files
echo.
pause
