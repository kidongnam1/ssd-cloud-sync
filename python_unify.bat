@echo off
chcp 65001 > nul
echo [Seoul-Gwangyang PC] Python 3.12 Standardizer (C:\Python312)
winget install -e --id Python.Python.3.12 --scope machine --custom "InstallAllUsers=1 PrependPath=1 TargetDir=C:\Python312" --accept-package-agreements --accept-source-agreements
C:\Python312\python.exe -m pip install --upgrade pip requests playwright beautifulsoup4 openpyxl pandas pywebview flask streamlit openai anthropic
C:\Python312\python.exe --version
pause
