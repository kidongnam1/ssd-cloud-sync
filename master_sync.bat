
@echo off
@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion
set "SSD_DIR=%~dp0"
set "SSD_DIR=%SSD_DIR:~0,-1%"
set "SSD_DRIVE=%~d0"
set "TEMP_WORK_DIR=C:\temp_coding"
set "REMOTE_DIR=gdrive:coding_workspace"
set "ARCHIVE_ROOT=gdrive:coding_backup_archive"
set "EXCLUDE_FILE=%SSD_DIR%\rclone_exclude.txt"
set "ENV_FILE=%SSD_DIR%\.env_sync"

for /f %%I in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd_HHmmss"') do set "TIMESTAMP=%%I"
set "BACKUP_DIR=%ARCHIVE_ROOT%\%TIMESTAMP%"

if not exist "%ENV_FILE%" (
    echo TG_TOKEN=INPUT_TOKEN> "%ENV_FILE%"
    echo TG_CHAT_ID=INPUT_CHAT_ID>> "%ENV_FILE%"
    echo DISCORD_WEBHOOK=INPUT_WEBHOOK>> "%ENV_FILE%"
)
if not exist "%EXCLUDE_FILE%" (
    echo venv/**> "%EXCLUDE_FILE%"
    echo .venv/**>> "%EXCLUDE_FILE%"
    echo __pycache__/**>> "%EXCLUDE_FILE%"
    echo node_modules/**>> "%EXCLUDE_FILE%"
    echo _local_backup/**>> "%EXCLUDE_FILE%"
    echo *.pyc>> "%EXCLUDE_FILE%"
)
if exist "%TEMP_WORK_DIR%" (
    echo [Docking] Absorbing C:\temp_coding into SSD...
    rclone copy "%TEMP_WORK_DIR%" "%SSD_DIR%" --exclude-from "%EXCLUDE_FILE%" --progress
    rmdir /s /q "%TEMP_WORK_DIR%"
)
:MAIN_MENU
cls
echo =====================================================================
echo   [Hybrid SSD - Cloud - GitHub] Master Controller V5
echo   PC : %COMPUTERNAME%  /  Drive : %SSD_DRIVE% (%SSD_DIR%)
echo =====================================================================
echo   [1] Push (SSD to Google Drive + 30d Clean)
echo   [2] Pull (Google Drive to SSD)
echo   [3] Deploy All (GitHub Push + Google Drive Sync)
echo   [4] Setup 19:00 Auto-Schedule and Edit .env_sync
echo   [5] Safe Eject (Sync and Release SSD Lock)
echo   [0] Exit
echo =====================================================================
set /p menu="Select: "
if "%menu%"=="1" (
    rclone sync "%SSD_DIR%" "%REMOTE_DIR%" --exclude-from "%EXCLUDE_FILE%" --backup-dir "%BACKUP_DIR%" --progress
    rclone delete "%ARCHIVE_ROOT%" --min-age 30d
    pause & goto MAIN_MENU
)
if "%menu%"=="2" (
    rclone sync "%REMOTE_DIR%" "%SSD_DIR%" --exclude-from "%EXCLUDE_FILE%" --backup-dir "%SSD_DIR%\_local_backup\%TIMESTAMP%" --progress
    pause & goto MAIN_MENU
)
if "%menu%"=="3" (
    for /d %%D in ("%SSD_DIR%\*") do (
        if exist "%%D\.git" (pushd "%%D" & git add . & git commit -m "Auto sync %TIMESTAMP%" & git pull --rebase --autostash & git push --no-verify & popd)
    )
    rclone sync "%SSD_DIR%" "%REMOTE_DIR%" --exclude-from "%EXCLUDE_FILE%" --backup-dir "%BACKUP_DIR%" --progress
    pause & goto MAIN_MENU
)
if "%menu%"=="4" (
    schtasks /create /tn "SSD_Master_AutoSync" /tr "\"%SSD_DIR%\master_sync.bat\" --auto" /sc daily /st 19:00 /f
    start notepad "%ENV_FILE%"
    pause & goto MAIN_MENU
)
if "%menu%"=="5" (
    rclone sync "%SSD_DIR%" "%REMOTE_DIR%" --exclude-from "%EXCLUDE_FILE%" --backup-dir "%BACKUP_DIR%" --progress
    cd /d C:\
    echo [Safe to Eject USB Drive!]
    pause & exit /b
)
if "%menu%"=="0" exit /b
goto MAIN_MENU



