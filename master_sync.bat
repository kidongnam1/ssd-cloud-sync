@echo off
chcp 65001 > nul
title 남기동 대표님 외장 SSD 초고속 통합 마스터 (v2.0)
:MENU
cls
echo ============================================================
echo   🚀 남기동 대표님 외장 SSD 초고속 통합 마스터 (v2.0)
echo   - 일상 코딩(3/5번): F:\program + F:\program-kdn (3.7초 컷)
echo   - 전체 백업(6번)  : F:\ 업무·개인 전체 알짜 폴더 통백업
echo ============================================================
echo.
echo   [3] 🔄 출근/작업 시작 (코딩 폴더 초고속 양방향 동기화)
echo   [4] ☁️ 코딩 폴더 클라우드 강제 업로드
echo   [5] ⏏️ 퇴근/SSD 분리 (코딩 백업 후 안전 분리)
echo   [6] 📦 F: 드라이브 전체 알짜 폴더 통백업 (야간/퇴근 시 추천)
echo   [0] ❌ 창 닫기
echo.
set /p sel=원하시는 번호를 선택하세요 (3/4/5/6/0): 
if "%sel%"=="3" goto SYNC_FAST
if "%sel%"=="4" goto UPLOAD_FAST
if "%sel%"=="5" goto EJECT_SAFE
if "%sel%"=="6" goto FULL_BACKUP
if "%sel%"=="0" exit
goto MENU

:SYNC_FAST
echo.
echo 🔄 [1/2] 구글 드라이브 최신본 받아오기...
rclone copy "gdrive:coding_workspace/program" "F:\program" --exclude-from "F:\program\rclone_exclude.txt" --transfers 8 --fast-list -P
rclone copy "gdrive:coding_workspace/program-kdn" "F:\program-kdn" --exclude-from "F:\program\rclone_exclude.txt" --transfers 8 --fast-list -P
echo ☁️ [2/2] 내 PC 최신본 클라우드로 올리기...
rclone copy "F:\program" "gdrive:coding_workspace/program" --exclude-from "F:\program\rclone_exclude.txt" --transfers 8 --fast-list -P
rclone copy "F:\program-kdn" "gdrive:coding_workspace/program-kdn" --exclude-from "F:\program\rclone_exclude.txt" --transfers 8 --fast-list -P
echo.
echo ✔ 3.7초 초고속 동기화 완료!
pause
goto MENU

:UPLOAD_FAST
rclone copy "F:\program" "gdrive:coding_workspace/program" --exclude-from "F:\program\rclone_exclude.txt" --transfers 8 --fast-list -P
rclone copy "F:\program-kdn" "gdrive:coding_workspace/program-kdn" --exclude-from "F:\program\rclone_exclude.txt" --transfers 8 --fast-list -P
echo ✔ 업로드 완료!
pause
goto MENU

:EJECT_SAFE
rclone copy "F:\program" "gdrive:coding_workspace/program" --exclude-from "F:\program\rclone_exclude.txt" --transfers 8 --fast-list -P
rclone copy "F:\program-kdn" "gdrive:coding_workspace/program-kdn" --exclude-from "F:\program\rclone_exclude.txt" --transfers 8 --fast-list -P
echo ⏏️ 외장 SSD(F:) 안전 분리 준비 중...
powershell -NoProfile -Command "(New-Object -comObject Shell.Application).Namespace(17).ParseName('F:').InvokeVerb('Eject')"
echo ✔ 이제 외장 SSD 케이블을 안전하게 뽑으셔도 됩니다!
pause
exit

:FULL_BACKUP
echo.
echo 📦 [F: 드라이브 전체 알짜 폴더 통백업 시작]
rclone copy "F:\" "gdrive:F:" --exclude-from "F:\program\rclone_exclude.txt" --transfers 8 --fast-list -P
echo.
echo ✔ F: 드라이브 전체 알짜 폴더 백업 완료!
pause
goto MENU
