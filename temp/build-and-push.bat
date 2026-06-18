@echo off
REM Build and Push API Image to GHCR (Windows)
REM Usage: build-and-push.bat <version>

setlocal

if "%1"=="" (
    set VERSION=v1.0.0
) else (
    set VERSION=%1
)

set GITHUB_USER=khanh030106
set IMAGE=ghcr.io/%GITHUB_USER%/w10-api:%VERSION%

echo ================================================
echo Building image: %IMAGE%
echo ================================================

cd src\api
docker build -t %IMAGE% .

if %errorlevel% neq 0 (
    echo Build failed!
    exit /b %errorlevel%
)

echo.
echo ================================================
echo Pushing image: %IMAGE%
echo ================================================

docker push %IMAGE%

if %errorlevel% neq 0 (
    echo Push failed!
    exit /b %errorlevel%
)

echo.
echo ================================================
echo SUCCESS!
echo Image: %IMAGE%
echo ================================================
echo.
echo Next steps:
echo 1. Update app-api/rollout.yaml with new image
echo 2. git add . ^&^& git commit -m "Update image to %VERSION%"
echo 3. git push origin main

cd ..\..
endlocal
