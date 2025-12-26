@echo off
echo ========================================
echo MRIT Hub - Windows Deployment Script
echo ========================================
echo.

REM Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker is not running!
    echo Please start Docker Desktop and try again.
    pause
    exit /b 1
)

REM Check if nginx container is running
docker ps | findstr mrit-nginx >nul 2>&1
if errorlevel 1 (
    echo ERROR: mrit-nginx container is not running!
    echo Please run start.bat first to start all services.
    pause
    exit /b 1
)

REM Copy frontend files to nginx container
echo Deploying frontend files to nginx...
cd frontend

for %%f in (*.html *.js *.jpg) do (
    if exist "%%f" (
        docker cp "%%f" mrit-nginx:/usr/share/nginx/html/
        echo Copied %%f
    )
)

cd ..

echo.
echo Frontend deployment complete!
echo Access the application at: http://localhost:8080
echo.
echo Login with:
echo   Email: faculty@mysururoyal.org
echo   Password: password123
echo.
pause
