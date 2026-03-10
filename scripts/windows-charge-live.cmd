@echo off
setlocal

chcp 65001 >nul
set "SCRIPT_DIR=%~dp0"
set "PS_SCRIPT=%SCRIPT_DIR%windows-charge-live.ps1"

where pwsh >nul 2>&1
if %errorlevel% equ 0 (
  pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%" %*
  exit /b %errorlevel%
)

powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%" %*
exit /b %errorlevel%
