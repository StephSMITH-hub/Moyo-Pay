@echo off
title Moyo-Pay - Continuous Auto-Sync Watcher
cd /d "%~dp0"

echo ========================================================
echo   Moyo-Pay: Starting Continuous Auto-Sync Watcher
echo   (Checks every 45s for file modifications and syncs)
echo ========================================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0sync-tools\auto_sync_watcher.ps1" %*

pause
