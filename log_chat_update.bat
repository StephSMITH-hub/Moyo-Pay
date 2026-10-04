@echo off
title Moyo-Pay - Log Chat Update & Sync
cd /d "%~dp0"

echo ========================================================
echo   Moyo-Pay: Log Chat Update and Sync to GitHub
echo ========================================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0sync-tools\log_chat_update.ps1" %*

echo.
echo ========================================================
echo Execution complete.
echo ========================================================
pause
