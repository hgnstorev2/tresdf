@echo off
setlocal enabledelayedexpansion

:: === CONFIG ===
set "nircmdPath=%~dp0nircmd.exe"
set "nircmdUrl=https://www.nirsoft.net/utils/nircmd.zip"
set "tempZip=%TEMP%\nircmd.zip"

:: === DOWNLOAD NIRCMD IF MISSING (SILENTLY) ===
if not exist "%nircmdPath%" (
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%nircmdUrl%', '%tempZip%')" >nul 2>&1
    powershell -Command "Expand-Archive -Path '%tempZip%' -DestinationPath '%~dp0' -Force" >nul 2>&1
    del "%tempZip%" >nul 2>&1
)

:: === DELETE PRIME SHORTCUTS FROM DESKTOPS ===
set "desktop1=%USERPROFILE%\Desktop\Prime.lnk"
set "desktop2=%PUBLIC%\Desktop\Prime.lnk"

if exist "%desktop1%" del /f /q "%desktop1%"
if exist "%desktop2%" del /f /q "%desktop2%"

:: === MONITOR LOOP TO HIDE PRIME WINDOWS ===
:loop
for /f "usebackq tokens=*" %%A in (`powershell -NoProfile -Command "Get-Process | Where-Object { $_.MainWindowTitle -like '*Prime*' } | Select-Object -ExpandProperty MainWindowTitle"`) do (
    set "title=%%A"
    if not "!title!"=="" (
        "%nircmdPath%" win hide title "!title!" >nul 2>&1
    )
)

:: === WAIT BEFORE LOOPING AGAIN ===
timeout /t 1 >nul
goto loop
