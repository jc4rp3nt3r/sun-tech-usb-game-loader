@echo off
setlocal enabledelayedexpansion
title SUN Tech Unlimited - Game Grid
color 06
cd /d "%~dp0"

echo.
echo    SUN TECH UNLIMITED  ///  GAME GRID
echo    ----------------------------------------------
echo    Starting up. Leave this window open while you play.
echo.

rem ---------------------------------------------------------------------------
rem  Find something that can run the launcher. Four options, best first.
rem ---------------------------------------------------------------------------

rem  1. Node bundled on this drive - works on a locked-down school PC with
rem     no admin rights and no internet.
if exist "system\runtime\win-x64\node.exe" (
  echo    Using the copy of Node on this drive.
  "system\runtime\win-x64\node.exe" "system\server.js"
  goto :done
)

rem  2. A single-file build, if one was made.
if exist "system\SunTechUnlimited.exe" (
  echo    Using the bundled launcher.
  "system\SunTechUnlimited.exe"
  goto :done
)

rem  3. Node already installed on this machine.
where node >nul 2>nul
if %errorlevel%==0 (
  echo    Using the Node already installed on this computer.
  node "system\server.js"
  goto :done
)

rem  4. No Node anywhere. Fall back to PowerShell, which every Windows
rem     machine already has. Slower, but it needs nothing installed.
echo    Node was not found - falling back to PowerShell.
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "system\server.ps1"
if %errorlevel% neq 0 goto :nofallback
goto :done

:nofallback
echo.
echo    ------------------------------------------------------------
echo    The Game Grid could not start.
echo.
echo    Ask whoever set this drive up to run  SETUP-RUNTIME.bat  once
echo    on a computer with internet. That copies Node onto the drive
echo    and this stops happening on every machine.
echo    ------------------------------------------------------------
echo.
pause
exit /b 1

:done
echo.
echo    The Game Grid has shut down.
timeout /t 3 >nul
endlocal
