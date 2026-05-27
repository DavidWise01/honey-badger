@echo off
echo davw shareware v0.3 - machine-rooted
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)
powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0install-davw-context.ps1"
echo.
pause
