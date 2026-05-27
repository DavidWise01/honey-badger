@echo off
title Honey Badger v1.0 — davw installer
echo.
echo  Honey Badger v1.0
echo  Right-click file signing for Windows
echo  Root: 6DD8EE25...B58BF (DAVID, 2026-05-08)
echo.

:: Elevate if needed (install-davw-context.ps1 uses HKCU so admin not required,
:: but some systems restrict PowerShell execution without elevation)
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo  Requesting elevation...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: Run the installer
pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0install-davw-context.ps1"
if %errorlevel% neq 0 (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install-davw-context.ps1"
)

echo.
pause
