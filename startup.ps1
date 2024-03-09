#Windows Startup Script
#Variablen
$hostname = HOSTNAME.EXE        #Hostname des Geräts
$user = [Security.Principal.WindowsIdentity]::GetCurrent(); #Hohlt die aktuellen Rechte
$isAdmin = $false
#Hue Variablen
$sucess = $true
$hueBridge = "http://192.168.178.29/api"        #Hue API
$username = 'K65vhYFKvPhk8vLzYohZwF7EE999xPOtywgWtdDk'      #API Username
$time = Get-Date -Format "HH:mm"    #Hohlt die Zeit
#Hue Play Lampen
$lights = @() 
$lights += 1 
$lights += 2
$lights += 3

#logs
if ($hostname = 'Einstein') {
    #Überprüft den Hostname und setzt den Pfad für die Logs
    $log = "D:\Code\_log\startup.log"
}
elseif ($hostname = 'William') {
    #Überprüft den Hostname und setzt den Pfad für die Logs
    $log = "C:\Code\log\startup.log"
}
else {
    mkdir C:\log\
    $log = "C:\Users\maxim\AppData\Local\Temp\startup.log"
} 

#Überprüft ob das Script mit Adminrechten läuft
if ((New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    $isAdmin = $true
}

#Wenn das Script mit Adminrechten läuft, wird der TimeSync Service gestartet und die Time wieder gesynct (Danke dafür Linux!)
if ($isAdmin) { 
    $ServiceName = 'w32time'
    $arrService = Get-Service -Name $ServiceName

    if ($arrService.Status -ne 'Running') {
        $ServiceStarted = $false
    }
    Else { $ServiceStarted = $true }

    while ($ServiceStarted -ne $true) {
        Start-Service $ServiceName
        write-host $arrService.status
        write-host 'Service started'
        $arrService = Get-Service -Name $ServiceName #Why is this line needed?
        if ($arrService.Status -eq 'Running') {
            $ServiceStarted = $true
        }
    }
    #net start w32time
    "$(get-date -format "yyyy-MM-dd HH:mm:ss"): w32time Service gestartet" | out-file $log -Append 
    W32tm /resync | Out-Null
    "$(get-date -format "yyyy-MM-dd HH:mm:ss"): Zeit wurde gesynct" | out-file $log -Append
}
else {
    "$(get-date -format "yyyy-MM-dd HH:mm:ss"): Kein Time Sync, da keine Adminrechte" | out-file $log -Append
}



#Schaut nach ob es nach 19:00 Uhr ist
if ($time -gt "19:00") {
    "$(get-date -format "yyyy-MM-dd HH:mm:ss"): Es ist nach 19:00 Uhr" | out-file $log -Append
    #Schaut ob die Hue Bridge erreichbar ist!
    if (Test-Connection -TargetName 192.168.178.29 -Quiet) {
        foreach ($light in $lights) {
    
#             $status = Invoke-RestMethod -Method Get -Uri "$($hueBridge)/$($username)/lights"
#             $currentState = $status.$light | Select-Object state
    
            If ($currentState.state.on.Equals($false)) {
                $body = @{"on" = $true } | ConvertTo-Json
                "$(get-date -format "yyyy-MM-dd HH:mm:ss"): Lampe $($light) war aus, und wurde angeschaltet" | out-file $log -Append
                $sucess = $true
    
            } 
            else {
                $body = @{"on" = $false } | ConvertTo-Json
                "$(get-date -format "yyyy-MM-dd HH:mm:ss"): Lampe $($light) war an, und wurde ausgeschaltet" | out-file $log -Append
                $sucess = $false
            }
        
#             Invoke-RestMethod -Method PUT -Uri "$($hueBridge)/$($username)/lights/$($light)/state" -Body $body | Out-Null
#             #$result
#         }
    
        if ($sucess) {
            "$(get-date -format "yyyy-MM-dd HH:mm:ss"): Hue wurde angemacht" | out-file $log -Append
        }   
        else {
            "$(get-date -format "yyyy-MM-dd HH:mm:ss"): Hue wurde ausgemacht" | out-file $log -Append
        } 
    }
    else {
        "$(get-date -format "yyyy-MM-dd HH:mm:ss"): Keine Verbindung zu Hue möglich" | out-file $log -Append
    }
}
else {
    "$(get-date -format "yyyy-MM-dd HH:mm:ss"): Noch keine 19:00 Uhr" | out-file $log -Append
}}



if ($hostname = 'Einstein') {
    #Überprüft ob das Script auf dem HauptPC ausgeführt wird und wenn setzt die Standard Audioquelle auf die System von GOXLR
    "$(get-date -format "yyyy-MM-dd HH:mm:ss"): Richtiges System" | out-file $log -Append

    If (! (Get-Module -Name "AudioDeviceCmdlets" -ListAvailable)) {            
        $url = 'https://github.com/frgnca/AudioDeviceCmdlets/releases/download/v3.0/AudioDeviceCmdlets.dll'
        $location = ($profile | split-path) + "\Modules\AudioDeviceCmdlets\AudioDeviceCmdlets.dll"
        New-Item "$($profile | split-path)\Modules\AudioDeviceCmdlets" -Type directory -Force
         
        [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
            (New-Object System.Net.WebClient).DownloadFile($url, $location)
        "$(get-date -format "yyyy-MM-dd HH:mm:ss"): Audio Module wurden installiert" | out-file $log -Append
    
    }

    If (! (Get-Module -Name "AudioDeviceCmdlets")) {
        get-module -Name "AudioDeviceCmdlets" -ListAvailable | Sort-Object Version | Select-Object -last 1 | Import-Module -Verbose
    }

    Get-AudioDevice -List | Where-Object Type -like "Playback" | Where-Object name -like "*System*" | Set-AudioDevice -Verbose | Out-Null
    "$(get-date -format "yyyy-MM-dd HH:mm:ss"): Soundquelle wurde auf System geändert" | out-file $log -Append
}
else {
    "$(get-date -format "yyyy-MM-dd HH:mm:ss"): Falsches System" | out-file $log -Append
 } #>

#Lösche Inhalt des Temp Ordners

#Remove-Item -Path "C:\Users\maxim\AppData\Local\Temp\*" -Recurse | Out-Null
#"$(get-date -format "yyyy-MM-dd HH:mm:ss"): Temp Ordner wurde bereinigt" | out-file $log -Append