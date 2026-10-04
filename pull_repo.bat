@echo off
title Moyo-Pay - Pull Repository Updates from GitHub
cd /d "%~dp0"

echo ========================================================
echo   Moyo-Pay: Pull Latest Updates from GitHub
echo ========================================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0sync-tools\pull_repo.ps1" %*

echo.
echo ========================================================
echo Execution complete.
echo ========================================================
pause
