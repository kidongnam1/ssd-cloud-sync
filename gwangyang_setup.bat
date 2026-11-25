@echo off
title Gwangyang PC rclone Auto Setup
cls
echo ============================================================
echo   [GWANGYANG PC] rclone Google Drive Auto Setup
echo ============================================================
echo.
rclone listremotes | findstr /i "gdrive:" >nul
if 0==0 (
  echo [INFO] gdrive is already configured on this PC!
  echo Testing connection...
  rclone lsd gdrive:coding_workspace
  echo.
  echo Launching SSD_Master...
  call "F:\program\ssd-cloud-sync\master_sync.bat"
  exit /b
)
echo [STEP 1] Paste your personal Google API credentials below.
echo (Tip: Check on phone via Termux: pc -> type %C:\Users\kidon\AppData\Roaming%\rclone\rclone.conf)
echo.
set /p CID=1. Paste client_id     : 
set /p CSEC=2. Paste client_secret : 
echo.
echo [STEP 2] Opening browser for Google Drive authorization...
echo Please log in with your Google account and click Allow until you see Success!
echo.
rclone config create gdrive drive client_id "%CID%" client_secret "%CSEC%" scope drive
echo.
echo [STEP 3] Verifying connection (Checking for zero NOTICE warnings)...
rclone lsd gdrive:coding_workspace
echo.
echo [DONE] Gwangyang PC rclone setup is 100%% complete!
pause
call "F:\program\ssd-cloud-sync\master_sync.bat"
