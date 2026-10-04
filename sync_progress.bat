@echo off
title Moyo-Pay - Auto Sync Progress to GitHub
cd /d "%~dp0"

echo ========================================================
echo   Moyo-Pay: Synchronizing Progress to GitHub
echo ========================================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0sync-tools\sync_progress.ps1" %*

echo.
echo ========================================================
echo Execution complete.
echo ========================================================
pause
