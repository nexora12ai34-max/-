@echo off
setlocal
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0HAMRAZ_ONE_CLICK_BUILD.ps1" -Target Menu
if errorlevel 1 (
  echo.
  echo HAMRAZ BUILD TOOL FAILED.
  pause
  exit /b 1
)
