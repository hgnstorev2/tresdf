@echo off
setlocal enabledelayedexpansion

:: === CONFIG ===
set "rustdeskPath=C:\Program Files\RustDesk\RustDesk.exe"
set "nircmdPath=%~dp0nircmd.exe"
set "logFile=%~dp0debug_log.txt"
set "nircmdUrl=https://www.nirsoft.net/utils/nircmd.zip"
set "tempZip=%TEMP%\nircmd.zip"

:: === CLEAR LOG ===
echo [STARTING] > "%logFile%"

:: === CHECK FOR NIRCMD ===
echo Checking for NirCmd... >> "%logFile%"
if not exist "%nircmdPath%" (
    echo NirCmd not found. Downloading... >> "%logFile%"
    echo NirCmd not found. Downloading...

    :: Download NirCmd using PowerShell
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%nircmdUrl%', '%tempZip%')"
    if %ERRORLEVEL% NEQ 0 (
        echo ERROR: Failed to download NirCmd. >> "%logFile%"
        echo ERROR: Failed to download NirCmd.
        pause
        exit /b 1
    )

    :: Extract NirCmd using PowerShell
    powershell -Command "Expand-Archive -Path '%tempZip%' -DestinationPath '%~dp0' -Force"
    if %ERRORLEVEL% NEQ 0 (
        echo ERROR: Failed to extract NirCmd. >> "%logFile%"
        echo ERROR: Failed to extract NirCmd.
        pause
        exit /b 1
    )

    :: Clean up the temporary zip file
    del "%tempZip%"
    if %ERRORLEVEL% NEQ 0 (
        echo WARNING: Failed to delete temporary zip file. >> "%logFile%"
        echo WARNING: Failed to delete temporary zip file.
    )

    echo NirCmd downloaded and extracted successfully. >> "%logFile%"
    echo NirCmd downloaded and extracted successfully.
) else (
    echo NirCmd found. >> "%logFile%"
    echo NirCmd found.
)

:: === START RUSTDESK AND HIDE IMMEDIATELY ===
echo Launching RustDesk... >> "%logFile%"
start "" "%rustdeskPath%"
if errorlevel 1 (
    echo ERROR: Failed to launch RustDesk >> "%logFile%"
    echo ERROR: Failed to launch RustDesk
    pause
    exit /b 1
)

:: === HIDE RUSTDESK WINDOW ===
echo Hiding RustDesk window... >> "%logFile%"
"%nircmdPath%" win hide class "Qt5QWindowIcon"
if errorlevel 1 (
    echo ERROR: Failed to hide RustDesk window >> "%logFile%"
    echo ERROR: Failed to hide RustDesk window
)

:loop
:: === SEARCH & HIDE RUSTDESK WINDOWS (FOR ANY NEW WINDOWS) ===
for /f "usebackq tokens=*" %%A in (`powershell -NoProfile -Command "Get-Process | Where-Object { $_.MainWindowTitle -like '*RustDesk*' } | Select-Object -ExpandProperty MainWindowTitle"`) do (
    set "title=%%A"
    if not "!title!"=="" (
        echo Hiding: !title! >> "%logFile%"
        "%nircmdPath%" win hide title "!title!"
        if errorlevel 1 (
            echo ERROR: Failed to hide window "!title!" >> "%logFile%"
            echo ERROR: Failed to hide window "!title!"
        )
    )
)

:: === WAIT BEFORE CHECKING AGAIN ===
timeout /t 0 >nul
goto loop
