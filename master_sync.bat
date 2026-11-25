@echo off
title Nam Ki-dong SSD Master Sync (v2.4)
if /i "%~1"=="auto4" goto AUTO_UPLOAD
:MENU
cls
echo ============================================================
echo   [NAM KI-DONG] External SSD Master Sync (v2.4)
echo   - [3] Start Work : Fast 2-Way Coding Sync (3.7s)
echo   - [4] Force Push : Upload Coding Folders Only
echo   - [5] Fast Eject : Backup Today's Changes (24h) + Eject F:
echo   - [6] Full Backup: Sync All Clean Folders on F: to Drive
echo ============================================================
echo.
echo   [3] Start Work  - Fast Coding Sync (program + program-kdn)
echo   [4] Upload Code - Force Upload Coding Folders to Drive
echo   [5] Fast Eject  - Backup Modified Files (24h) + Eject F:
echo   [6] Full Backup - Backup Entire Clean F: Drive (Weekly)
echo   [0] Exit
echo.
set /p sel=Select Menu (3/4/5/6/0): 
if "%sel%"=="3" goto SYNC_FAST
if "%sel%"=="4" goto UPLOAD_FAST
if "%sel%"=="5" goto EJECT_FAST
if "%sel%"=="6" goto FULL_BACKUP
if "%sel%"=="0" exit
goto MENU

:SYNC_FAST
echo.
echo [1/2] Downloading latest coding files from Google Drive...
rclone copy "gdrive:coding_workspace" "F:\program" --exclude-from "F:\program\rclone_exclude.txt" --transfers 8 --fast-list -P
rclone copy "gdrive:coding_workspace/program-kdn" "F:\program-kdn" --exclude-from "F:\program\rclone_exclude.txt" --transfers 8 --fast-list -P
echo [2/2] Uploading local coding changes to Google Drive...
rclone copy "F:\program" "gdrive:coding_workspace" --exclude-from "F:\program\rclone_exclude.txt" --transfers 8 --fast-list -P
rclone copy "F:\program-kdn" "gdrive:coding_workspace/program-kdn" --exclude-from "F:\program\rclone_exclude.txt" --transfers 8 --fast-list -P
echo.
echo [DONE] Fast 2-Way Coding Sync Completed!
pause
goto MENU

:UPLOAD_FAST
echo.
rclone copy "F:\program" "gdrive:coding_workspace" --exclude-from "F:\program\rclone_exclude.txt" --transfers 8 --fast-list -P
rclone copy "F:\program-kdn" "gdrive:coding_workspace/program-kdn" --exclude-from "F:\program\rclone_exclude.txt" --transfers 8 --fast-list -P
echo.
echo [DONE] Coding Upload Completed!
pause
goto MENU

:EJECT_FAST
echo.
echo [1/3] Uploading today's coding changes (max-age 24h)...
rclone copy "F:\program" "gdrive:coding_workspace" --exclude-from "F:\program\rclone_exclude.txt" --max-age 24h --transfers 8 -P
rclone copy "F:\program-kdn" "gdrive:coding_workspace/program-kdn" --exclude-from "F:\program\rclone_exclude.txt" --max-age 24h --transfers 8 -P
echo [2/3] Uploading today's modified F: files (max-age 24h)...
rclone copy F:/ "gdrive:F:" --exclude-from "F:\program\rclone_exclude.txt" --max-age 24h --transfers 8 -P
echo [3/3] Safely ejecting External SSD (F:)...
powershell -NoProfile -Command "(New-Object -comObject Shell.Application).Namespace(17).ParseName('F:').InvokeVerb('Eject')"
echo.
echo [DONE] Backup Complete & F: Drive Safely Ejected!
pause
exit

:FULL_BACKUP
echo.
echo [Starting Full Clean Backup of F: Drive...]
rclone copy F:/ "gdrive:F:" --exclude-from "F:\program\rclone_exclude.txt" --transfers 8 --fast-list -P
echo.
echo [DONE] Full Clean Backup Completed!
pause
goto MENU
:AUTO_UPLOAD
if not exist F:\program exit /b
rclone copy "F:\program" "gdrive:coding_workspace/program" --exclude-from "F:\program\rclone_exclude.txt" --transfers 8 --fast-list
rclone copy "F:\program-kdn" "gdrive:coding_workspace/program-kdn" --exclude-from "F:\program\rclone_exclude.txt" --transfers 8 --fast-list
exit /b
