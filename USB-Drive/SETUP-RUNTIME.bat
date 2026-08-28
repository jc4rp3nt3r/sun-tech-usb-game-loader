@echo off
setlocal
title SUN Tech Unlimited - one-time setup
color 06
cd /d "%~dp0"

echo.
echo    SUN TECH UNLIMITED  ///  ONE-TIME SETUP
echo    ==============================================
echo.
echo    This copies Node onto the drive so the Game Grid works on
echo    school computers that have nothing installed and no internet.
echo.
echo    You only need to run this ONCE, on a computer that has internet.
echo    After that the drive is self-contained forever.
echo.
echo    It downloads about 80 MB from nodejs.org - the official, signed
echo    build. Nothing is installed on this computer; the files go onto
echo    the drive only.
echo.
pause

set "NODE_VER=v22.22.0"
set "TMPZIP=%TEMP%\suntech-node.zip"
set "TMPDIR=%TEMP%\suntech-node"
set "URL=https://nodejs.org/dist/%NODE_VER%/node-%NODE_VER%-win-x64.zip"

echo.
echo    Downloading Node %NODE_VER% ...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ProgressPreference='SilentlyContinue'; try { Invoke-WebRequest -Uri '%URL%' -OutFile '%TMPZIP%' -UseBasicParsing } catch { Write-Host ''; Write-Host ('   Download failed: ' + $_.Exception.Message); exit 1 }"
if %errorlevel% neq 0 goto :failed
if not exist "%TMPZIP%" goto :failed

echo    Unpacking ...
if exist "%TMPDIR%" rmdir /s /q "%TMPDIR%"
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ProgressPreference='SilentlyContinue'; Expand-Archive -Path '%TMPZIP%' -DestinationPath '%TMPDIR%' -Force"
if %errorlevel% neq 0 goto :failed

echo    Copying onto the drive ...
if not exist "system\runtime\win-x64" mkdir "system\runtime\win-x64"
copy /y "%TMPDIR%\node-%NODE_VER%-win-x64\node.exe" "system\runtime\win-x64\node.exe" >nul
if %errorlevel% neq 0 goto :failed

del /q "%TMPZIP%" 2>nul
rmdir /s /q "%TMPDIR%" 2>nul

echo.
echo    ----------------------------------------------------------
echo    Done. Node is now on the drive.
echo.
echo    The Game Grid will work on any Windows computer from here,
echo    with or without internet, with or without admin rights.
echo.
echo    Run START.bat to try it.
echo    ----------------------------------------------------------
echo.
pause
exit /b 0

:failed
echo.
echo    ----------------------------------------------------------
echo    Setup could not finish.
echo.
echo    Check that this computer has internet and that nodejs.org
echo    is not blocked, then run this again.
echo.
echo    You can also do it by hand:
echo      1. Go to  https://nodejs.org/dist/%NODE_VER%/
echo      2. Download  node-%NODE_VER%-win-x64.zip
echo      3. Open it and find  node.exe
echo      4. Copy node.exe into  system\runtime\win-x64\  on this drive
echo.
echo    The Game Grid still works without this - it falls back to
echo    PowerShell. This just makes it faster and more reliable.
echo    ----------------------------------------------------------
echo.
pause
exit /b 1
