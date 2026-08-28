@echo off
title SUN Tech Unlimited - copy to USB
color 06
cd /d "%~dp0"

set "MODE=update"
if /i "%~1"=="clean" set "MODE=clean"

echo.
echo    SUN TECH UNLIMITED  ///  COPY TO USB
echo    ==================================================
echo.

if not exist "USB-Drive\START.bat" goto :nosource

echo    Removable drives on this computer:
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_LogicalDisk | Where-Object DriveType -eq 2 | ForEach-Object { Write-Host ('      ' + $_.DeviceID + '  ' + $_.VolumeName + '   ' + [math]::Round($_.FreeSpace/1GB,1) + ' GB free of ' + [math]::Round($_.Size/1GB,1) + ' GB') }"
echo.

set "TARGET="
set /p TARGET=   Which drive letter?  (just the letter, e.g. E)  
if "%TARGET%"=="" goto :nothing

set "DRIVE=%TARGET::=%"
set "DRIVE=%DRIVE:~0,1%"
set "DEST=%DRIVE%:\"

if not exist "%DRIVE%:\*" goto :nodrive

rem --- Never touch the drive Windows is running from.
if /i "%DRIVE%:"=="%SystemDrive%" goto :systemdrive

rem --- What kind of drive is this? No pipes in here: a pipe inside a
rem --- for /f command block does not survive cmd's parser, which is what
rem --- broke the previous version of this script.
set "DTYPE=Unknown"
for /f "usebackq tokens=*" %%T in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "try { (Get-Volume -DriveLetter %DRIVE% -ErrorAction Stop).DriveType } catch { 'Unknown' }"`) do set "DTYPE=%%T"

echo.
echo    Target : %DEST%   (detected as: %DTYPE%)
if /i "%MODE%"=="clean" echo    Mode   : CLEAN - wipes the drive first
if /i "%MODE%"=="update" echo    Mode   : update - adds and refreshes, deletes nothing

rem --- A fixed disk is almost certainly a mistake. Everything else proceeds;
rem --- an inconclusive check should ask, not block.
if /i "%DTYPE%"=="Fixed" goto :fixeddisk

if /i "%MODE%"=="clean" goto :confirmclean
goto :docopy

:confirmclean
echo.
echo    CLEAN mode deletes everything on %DEST% that is not part of
echo    the Game Grid - including any games students saved there.
echo.
set "OK="
set /p OK=   Type YES to continue, anything else to stop:  
if /i not "%OK%"=="YES" goto :stopped
goto :docopy

:docopy
echo.
echo    Copying to %DEST% ...
echo.
if /i "%MODE%"=="clean" goto :runclean

robocopy "USB-Drive" %DRIVE%:\ /E /R:2 /W:2 /NFL /NDL /NJH /NJS /NP
if errorlevel 8 goto :failed
echo.
echo    ------------------------------------------------------
echo    Done. %DEST% is up to date.
echo.
echo    Anything else on the drive was left alone, so games
echo    students saved onto the stick are still there.
echo    ------------------------------------------------------
goto :finish

:runclean
robocopy "USB-Drive" %DRIVE%:\ /MIR /R:2 /W:2 /NFL /NDL /NJH /NJS /NP
if errorlevel 8 goto :failed
echo.
echo    ------------------------------------------------------
echo    Done. %DEST% is now an exact copy of USB-Drive.
echo    ------------------------------------------------------
goto :finish

:finish
echo.
pause
exit /b 0

:nosource
echo    Can't find the USB-Drive folder next to this file.
echo    Expected: %~dp0USB-Drive\START.bat
goto :bail

:nothing
echo.
echo    Nothing entered. Stopping.
goto :bail

:nodrive
echo.
echo    Drive %DEST% is not there. Stopping.
goto :bail

:systemdrive
echo.
echo    %DEST% is the drive Windows runs from. Refusing.
goto :bail

:fixeddisk
echo.
echo    %DEST% is a fixed hard disk, not a removable drive.
echo    Refusing, in case that was a typo. Nothing was changed.
echo.
echo    If you really meant it, copy the USB-Drive folder there
echo    by hand in File Explorer.
goto :bail

:stopped
echo.
echo    Stopped. Nothing was changed.
goto :bail

:failed
echo.
echo    ------------------------------------------------------
echo    The copy did not finish. Check the drive is plugged in
echo    and not write-protected, then run this again.
echo    ------------------------------------------------------
goto :bail

:bail
echo.
pause
exit /b 1
