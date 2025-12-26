@echo off
echo ========================================
echo MRIT Hub - Windows Deployment Script
echo ========================================
echo.

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
pause
