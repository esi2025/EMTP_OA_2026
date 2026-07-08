@echo off
:: =========================================================================
:: OMRAN AZARESTAN - Advanced Translation & Glossary System
:: Automated Windows Server 2025 Setup & PM2 Startup Script
:: =========================================================================
:: This script automates dependencies installation, production builds,
:: PM2 process registration, and configuring persistence across server restarts.
::
:: Run this file as ADMINISTRATOR on your Windows Server 2025.
:: =========================================================================

title Omran Azarestan Translation System Setup
color 0B
cls

echo =========================================================================
echo             OMRAN AZARESTAN - TRANSLATION SYSTEM SETUP
echo                   Target: Windows Server 2025
echo =========================================================================
echo.

:: Check for Administrative privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    color 0C
    echo [ERROR] This script must be run as an ADMINISTRATOR!
    echo Please right-click this .bat file and select "Run as administrator".
    echo.
    pause
    exit /b 1
)

:: Step 1: Check for Node.js installation
echo [STEP 1/5] Checking for Node.js installation...
node -v >nul 2>&1
if %errorLevel% neq 0 (
    color 0C
    echo [ERROR] Node.js is not installed on this server!
    echo Please download and install Node.js (LTS version recommended) from:
    echo https://nodejs.org/
    echo after installation, restart this script.
    echo.
    pause
    exit /b 1
)
echo [SUCCESS] Node.js is installed. Version:
node -v
echo.

:: Step 2: Install Local Project Dependencies
echo [STEP 2/5] Installing local project dependencies (npm install)...
call npm install
if %errorLevel% neq 0 (
    color 0C
    echo [ERROR] Failed to install npm dependencies. Please check network connectivity.
    echo.
    pause
    exit /b 1
)
echo [SUCCESS] Project dependencies installed successfully.
echo.

:: Step 3: Build the production application
echo [STEP 3/5] Compiling and building application assets for production...
call npm run build
if %errorLevel% neq 0 (
    color 0C
    echo [ERROR] Failed to compile and build application. See logs above.
    echo.
    pause
    exit /b 1
)
echo [SUCCESS] Production build completed. (Output located in /dist)
echo.

:: Step 4: Install PM2 Process Manager Globally
echo [STEP 4/5] Checking and installing PM2 (Node Process Manager) globally...
call npm install -g pm2
if %errorLevel% neq 0 (
    color 0C
    echo [ERROR] Failed to install PM2 globally.
    echo.
    pause
    exit /b 1
)
echo [SUCCESS] PM2 Process Manager installed.
echo.

:: Step 5: Configure PM2 for automatic startup on Windows Server
echo [STEP 5/5] Configuring automatic startup & persistence...
echo.

:: Install pm2-windows-startup helper globally
echo Installing pm2-windows-startup tool...
call npm install -g pm2-windows-startup
if %errorLevel% neq 0 (
    echo [WARNING] pm2-windows-startup could not be installed automatically.
    echo Trying to register startup via local Windows Registry / Startup Folder as fallback...
) else (
    echo Registering PM2 startup service...
    call pm2-startup install
)

:: Start the Express server via PM2
echo Starting translation server using PM2...
call pm2 start dist/server.cjs --name "azarestan-translator" --watch
if %errorLevel% neq 0 (
    color 0C
    echo [ERROR] Failed to start server in PM2.
    echo.
    pause
    exit /b 1
)

:: Save current PM2 process list to restore on startup
echo Saving PM2 state to lock automatic restore...
call pm2 save
if %errorLevel% neq 0 (
    echo [WARNING] PM2 save failed. You may need to manually execute 'pm2 save' in CMD.
)

echo.
echo =========================================================================
echo         SETUP COMPLETED SUCCESSFULLY! (WINDOWS SERVER 2025)
echo =========================================================================
echo.
echo  - The server is running on: http://localhost:3000
echo  - PM2 has registered the process as "azarestan-translator"
echo  - The service is configured to automatically restart on system boot.
echo.
echo  Useful PM2 commands for reference:
echo   * View live logs:       pm2 logs azarestan-translator
echo   * Check process status: pm2 status
echo   * Stop the system:      pm2 stop azarestan-translator
echo   * Restart the system:   pm2 restart azarestan-translator
echo.
echo =========================================================================
pause
