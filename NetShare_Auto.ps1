<#
.SYNOPSIS
    Auto-proxy configuration for NetShare (Android) on Windows.
    
.DESCRIPTION
    Automatically toggles proxy (192.168.49.1:8282) based on Wi-Fi SSID (DIRECT-NS-).
    
.LICENSE
    Distributed under CC BY-ND 4.0. 
    Free to share and use, provided original authorship is maintained.
    (c) 2026 PlayToMind Studio. All rights reserved.
#>

# Admin Check
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERROR: Please run this script as ADMINISTRATOR!" -ForegroundColor Red
    Write-Host "PlayToMind Studio (c) 2026"
    pause ; exit
}

$configDir = "$env:APPDATA\NetShareAuto"
if (!(Test-Path $configDir)) { New-Item -ItemType Directory -Path $configDir | Out-Null }

$onBat = "$configDir\proxy_on.bat"
$offBat = "$configDir\proxy_off.bat"

# 1. Proxy ON Script (with SSID check)
$onContent = @"
@echo off
:: Created by PlayToMind Studio (c) 2026
netsh wlan show interfaces | findstr /C:" DIRECT-NS-" >nul
if %errorlevel%==0 (
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1 /f
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /t REG_SZ /d "192.168.49.1:8282" /f
    echo [NetShare] Proxy ENABLED (192.168.49.1:8282)
) else (
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f
    echo [NetShare] Normal network detected. Proxy DISABLED.
)
echo PlayToMind Studio (c) 2026
"@

# 2. Proxy OFF Script
$offContent = @"
@echo off
:: Created by PlayToMind Studio (c) 2026
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f
echo [NetShare] Connection lost. Proxy DISABLED.
echo PlayToMind Studio (c) 2026
"@

$onContent | Out-File -FilePath $onBat -Encoding ASCII
$offContent | Out-File -FilePath $offBat -Encoding ASCII

# 3. Task Scheduler Setup
$user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

# Task On
$actionOn = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c $onBat"
$triggerOn = New-ScheduledTaskTrigger -AtLogOn
$taskOn = Register-ScheduledTask -TaskName "NetShare_Proxy_AutoOn" -Action $actionOn -Trigger $triggerOn -User $user -Force
$taskOn.Triggers.Subscription = "<QueryList><Query Id='0' Path='Microsoft-Windows-NetworkProfile/Operational'><Select Path='Microsoft-Windows-NetworkProfile/Operational'>*[System[EventID=10000]]</Select></Query></QueryList>"
$taskOn | Set-ScheduledTask

# Task Off
$actionOff = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c $offBat"
$triggerOff = New-ScheduledTaskTrigger -AtLogOn
$taskOff = Register-ScheduledTask -TaskName "NetShare_Proxy_AutoOff" -Action $actionOff -Trigger $triggerOff -User $user -Force
$taskOff.Triggers.Subscription = "<QueryList><Query Id='0' Path='Microsoft-Windows-NetworkProfile/Operational'><Select Path='Microsoft-Windows-NetworkProfile/Operational'>*[System[EventID=10001]]</Select></Query></QueryList>"
$taskOff | Set-ScheduledTask

# 4. Immediate activation
Start-Process -FilePath $onBat -WindowStyle Hidden

Write-Host "-------------------------------------------------------" -ForegroundColor Cyan
Write-Host "SUCCESS: Automation has been configured!" -ForegroundColor Green
Write-Host "Proxy: 192.168.49.1:8282"
Write-Host "Target SSID: DIRECT-NS-*"
Write-Host "-------------------------------------------------------"
Write-Host "PlayToMind Studio (c) 2026" -ForegroundColor Yellow
Write-Host "License: CC BY-ND 4.0 (Free to distribute)"
Write-Host "-------------------------------------------------------"
pause
