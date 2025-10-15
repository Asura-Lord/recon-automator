@echo off
REM recon-automator wrapper: forwards args to the PowerShell helper
setlocal
set scriptdir=%~dp0
powershell -NoProfile -ExecutionPolicy Bypass -File "%scriptdir%recon-automator.ps1" %*
endlocal
