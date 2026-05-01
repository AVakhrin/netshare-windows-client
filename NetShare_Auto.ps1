<#
.SYNOPSIS
    Auto-proxy configurator for NetShare.
    
.DESCRIPTION
    Automatically toggles proxy settings (192.168.49.1:8282) based on 
    the current Wi-Fi SSID (detects DIRECT-NS- prefix).
    
.VERSION
    1.4 (Stable)
    
.AUTHOR
    PlayToMind Studio (c) 2026
    
.LICENSE
    Distributed under Creative Commons Attribution-NoDerivs 4.0 (CC BY-ND 4.0).
    Free to share and use, provided original authorship is maintained.
#>

# --- ADMIN CHECK ---
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "-------------------------------------------------------" -ForegroundColor Red
    Write-Host "ERROR: PLEASE RUN THIS SCRIPT AS ADMINISTRATOR!" -ForegroundColor Red
    Write-Host "PlayToMind Studio (c) 2026"
    Write-Host "-------------------------------------------------------" -ForegroundColor Red
    pause ; exit
}

# --- CONFIGURATION ---
$configDir = "$env:APPDATA\NetShareAuto"
if (!(Test-Path $configDir)) { New-Item -ItemType Directory -Path $configDir | Out-Null }

$onBat  = "$configDir\proxy_on.bat"
$offBat = "$configDir\proxy_off.bat"
$user   = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

# 1. CREATE HELPER SCRIPTS
# This script checks for SSID and enables proxy if it matches DIRECT-NS-
$onContent = "@echo off`nnetsh wlan show interfaces | findstr /C:`" DIRECT-NS-`" >nul`nif %errorlevel%==0 (reg add `"HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings`" /v ProxyEnable /t REG_DWORD /d 1 /f & reg add `"HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings`" /v ProxyServer /t REG_SZ /d `"192.168.49.1:8282`" /f) else (reg add `"HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings`" /v ProxyEnable /t REG_DWORD /d 0 /f)`necho PlayToMind Studio (c) 2026"

# This script simply disables proxy
$offContent = "@echo off`nreg add `"HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings`" /v ProxyEnable /t REG_DWORD /d 0 /f`necho PlayToMind Studio (c) 2026"

$onContent  | Out-File -FilePath $onBat  -Encoding ASCII -Force
$offContent | Out-File -FilePath $offBat -Encoding ASCII -Force

# 2. TASK SCHEDULER REGISTRATION (Low-level COM-Object Method)
function Register-NetShareTask ($TaskName, $ScriptPath, $EventID) {
    $service = New-Object -ComObject Schedule.Service
    $service.Connect()
    $rootFolder = $service.GetFolder("\")
    
    $taskDefinition = $service.NewTask(0)
    $taskDefinition.RegistrationInfo.Description = "NetShare Auto Proxy Trigger ($TaskName)"
    $taskDefinition.RegistrationInfo.Author = "PlayToMind Studio"
    
    # Settings for reliability
    $taskDefinition.Settings.AllowDemandStart = $true
    $taskDefinition.Settings.DisallowStartIfOnBatteries = $false
    $taskDefinition.Settings.StopIfGoingOnBatteries = $false
    $taskDefinition.Settings.ExecutionTimeLimit = "PT0S" # No limit
    
    # Create Event Trigger (EventID 10000 = Connect, 10001 = Disconnect)
    $triggers = $taskDefinition.Triggers
    $trigger = $triggers.Create(0) # 0 is EventTrigger type
    $trigger.Subscription = "<QueryList><Query Id='0' Path='Microsoft-Windows-NetworkProfile/Operational'><Select Path='Microsoft-Windows-NetworkProfile/Operational'>*[System[EventID=$EventID]]</Select></Query></QueryList>"
    
    # Create Action
    $actions = $taskDefinition.Actions
    $action = $actions.Create(0) # 0 is ExecAction type
    $action.Path = "cmd.exe"
    $action.Arguments = "/c `"$ScriptPath`""
    
    # Register Task: 6 = Create or Update, 3 = Interactive Token
    $rootFolder.RegisterTaskDefinition($TaskName, $taskDefinition, 6, $null, $null, 3) | Out-Null
}

Write-Host "Registering Automation Tasks..." -ForegroundColor Yellow

# Registering tasks for Connect and Disconnect events
Register-NetShareTask -TaskName "NetShare_Proxy_AutoOn" -ScriptPath $onBat -EventID 10000
Register-NetShareTask -TaskName "NetShare_Proxy_AutoOff" -ScriptPath $offBat -EventID 10001

# --- FINALIZATION ---
# Trigger the first check immediately in background
Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$onBat`"" -WindowStyle Hidden

Write-Host "-------------------------------------------------------" -ForegroundColor Cyan
Write-Host "SUCCESS: Automation has been configured!" -ForegroundColor Green
Write-Host "Proxy: 192.168.49.1:8282"
Write-Host "Target SSID: DIRECT-NS-*"
Write-Host "-------------------------------------------------------"
Write-Host "PlayToMind Studio (c) 2026" -ForegroundColor Yellow
Write-Host "License: CC BY-ND 4.0"
Write-Host "-------------------------------------------------------"
pause
