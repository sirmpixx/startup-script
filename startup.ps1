######################################################### Header ###################################################
# Scriptname: startup.ps1
# Date: 20.04.2024
# Version: 2.0
# Authour: Maximilian Lanski (sirmpixx)
# Synopsis: A startup script
######################################################### Update Log ###############################################
# Version 1.0: First Creation
# Version 2.o: Complete rewrite of the script
################################################## Global variables ################################################
$logfile = "D:\Coding\logs\startup.log"
##################################################### functions ####################################################
# Gives a Timestamp
function Get-Timestamp { 
    $Timestamp = Get-date -format "dd-MM-yyyy HH:mm:ss"
    return $Timestamp
}
# Write a LogEntry in a file with a timestamp
function Write-LogEntry {
Param($sLogEntry)

    (Get-Timestamp ) + "  " + $sLogEntry | Out-File $logfile -Append
} 
#Checks if the user have Adminstartor Rights
function Get-AdminRights {
    param (
        [bool]$isAdmin
    )
    ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}
#Start the w32time Service and sync the systemtime with a timeserver
function Start-TimeService {
    $ServiceName = 'w32time'
    $arrService = Get-Service -Name $ServiceName

    if ($arrService.Status -ne 'Running') {
        $ServiceStarted = $false
    }
    Else { $ServiceStarted = $true }

    while ($ServiceStarted -ne $true) {
        Start-Service $ServiceName
        $arrService = Get-Service -Name $ServiceName
        if ($arrService.Status -eq 'Running') {
            $ServiceStarted = $true
        }
    }
    W32tm /resync | Out-Null
}
#Set the Windows Audioplayback to a specifc Output Source
function Set-Playback{
    
    if ( $env:computername -eq "EINSTEIN") {

        If (! (Get-Module -Name "AudioDeviceCmdlets" -ListAvailable)) {            
            $url = 'https://github.com/frgnca/AudioDeviceCmdlets/releases/download/v3.0/AudioDeviceCmdlets.dll'
            $location = ($profile | split-path) + "\Modules\AudioDeviceCmdlets\AudioDeviceCmdlets.dll"
            New-Item "$($profile | split-path)\Modules\AudioDeviceCmdlets" -Type directory -Force
             
            [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
            (New-Object System.Net.WebClient).DownloadFile($url, $location)

        
        }
        If (! (Get-Module -Name "AudioDeviceCmdlets")) {
            get-module -Name "AudioDeviceCmdlets" -ListAvailable | Sort-Object Version | Select-Object -last 1 | Import-Module -Verbose
        }
        Get-AudioDevice -List | Where-Object Type -like "Playback" | Where-Object name -like "*CH5/6*" | Set-AudioDevice -Verbose | Out-Null
        Get-AudioDevice -List | Where-Object Type -like "Recording" | Where-Object name -like "*Voice*" | Set-AudioDevice -Verbose | Out-Null

    }
    
}
#Set the Windows Audioplayback to a specifc Input Source
function Set-Recording {
    if ( $env:computername -eq "EINSTEIN") {

        If (! (Get-Module -Name "AudioDeviceCmdlets" -ListAvailable)) {            
            $url = 'https://github.com/frgnca/AudioDeviceCmdlets/releases/download/v3.0/AudioDeviceCmdlets.dll'
            $location = ($profile | split-path) + "\Modules\AudioDeviceCmdlets\AudioDeviceCmdlets.dll"
            New-Item "$($profile | split-path)\Modules\AudioDeviceCmdlets" -Type directory -Force
             
            [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
            (New-Object System.Net.WebClient).DownloadFile($url, $location)

        
        }
        If (! (Get-Module -Name "AudioDeviceCmdlets")) {
            get-module -Name "AudioDeviceCmdlets" -ListAvailable | Sort-Object Version | Select-Object -last 1
        }
        Get-AudioDevice -List | Where-Object Type -like "Recording" | Where-Object name -like "*Voice*" | Set-AudioDevice -Verbose | Out-Null

    }
}
#Clears the Tempfolder
function Clear-TempFolder {
    Remove-Item -Path "C:\Users\maxim\AppData\Local\Temp\*" -Recurse  -ErrorAction SilentlyContinue | Out-Null 
    
}
##################################################### Main Script ##################################################
if (Get-AdminRights) {
    Write-LogEntry "Das Script läuft mit Adminrechten"
    Start-TimeService
    Write-LogEntry "Der Time Service wurde gestartet und die Zeit wurde gesynct"
    Set-Playback
    Write-LogEntry 'Audioeingang wurde auf "CH5/6" gestellt'
    Set-Recording
    Write-LogEntry 'Audioeingang wurde auf "Voice" gestellt'
    Clear-TempFolder
    Write-LogEntry "Der Temporder wurde bereinigt"
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    Write-LogEntry "Der Papierkorb wurde geleert"
}
else {
    Write-LogEntry "ERROR: Das Script wurde ohne Adminrechte gestartet und wurde abgebrochen"
    exit 1
}