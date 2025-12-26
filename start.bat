@echo off
echo Starting MRIT Hub v1...
echo.

REM Check if .env exists
if not exist .env (
    echo .env file not found. Creating from template...
    copy .env.example .env
    echo Created .env file. Please edit it with your credentials.
    echo.
)

REM Start Docker services
echo Starting Docker services...
docker-compose up -d

echo.
echo Waiting for services to be healthy...
timeout /t 10 /nobreak >nul

REM Check service status
echo.
echo Service Status:
docker-compose ps

echo.
echo MRIT Hub is starting!
echo.
echo Access points:
echo   - Frontend: http://localhost:8080
echo   - Backend API: http://localhost:3000
echo   - PostgreSQL: localhost:5432
echo   - Redis: localhost:6379
echo.
echo To view logs:
echo   docker-compose logs -f backend
echo.
echo To stop:
echo   docker-compose down
echo.
pause
