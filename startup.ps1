######################################################### Header ###################################################
# Scriptname: startup.ps1
# Date: 20.04.2024
# Version: 2.0
# Authour: Maximilian Lanski (sirmpixx)
# Synopsis: A startup script
######################################################### Update Log ###############################################
# Version 1.0: First Creation
# Version 2.0: Complete rewrite of the script
################################################## Global variables ################################################
$logfile = "/Path/to/log/XX.log"
$playback = "*[Set Playback])*"
$recording = "*[Set Recording])*"

##################################################### functions ####################################################
# Gives a Timestamp
function Get-Timestamp { 
    $Timestamp = Get-date -format "dd-MM-yyyy HH:mm:ss"
    return $Timestamp
}
# Write a LogEntry in a file with a timestamp
function Write-LogEntry {
Param($LogEntry)

    (Get-Timestamp ) + "  " + $LogEntry | Out-File $logfile -Append
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
        Get-AudioDevice -List | Where-Object Type -like "Playback" | Where-Object name -like $playback | Set-AudioDevice -Verbose | Out-Null
        

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
        Get-AudioDevice -List | Where-Object Type -like "Recording" | Where-Object name -like $recording | Set-AudioDevice -Verbose | Out-Null

    }
}
#Clears the Tempfolder
function Clear-TempFolder {
    $tmpfolder = $env:TEMP 
    $tmpfolder = "$($tmpfolder)\*"
    Remove-Item -Path "$tmpfolder" -Recurse  -ErrorAction SilentlyContinue | Out-Null 
    
}
##################################################### Main Script ##################################################
if (Get-AdminRights) {
    Write-LogEntry "This script runs with admin rights"
    Start-TimeService
    Write-LogEntry "Time Service started and synced"
    Set-Playback
    Write-LogEntry "Playback was set to $($playback)"
    Set-Recording
    Write-LogEntry "Recording was set to $($recording)"
    Clear-TempFolder
    Write-LogEntry "The temp folder was cleaned."
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    Write-LogEntry "The Recycling Bin was cleaned."
}
else {
    Write-LogEntry "ERROR: The script was started without administrator rights."
    exit 1
}