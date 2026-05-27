@echo off
title Honey Badger v1.0 — davw uninstaller
echo.
echo  Honey Badger v1.0 — uninstall
echo  Removing right-click context menu entries...
echo.

pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0install-davw-context.ps1" -Uninstall
if %errorlevel% neq 0 (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install-davw-context.ps1" -Uninstall
)

echo.
pause
