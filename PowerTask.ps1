$powerTaskPath = "$env:USERPROFILE\PowerTask"
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile("https://raw.githubusercontent.com/cylin2000/powertask/master/PowerTask.psm1","$powerTaskPath\PowerTask.psm1")
Import-Module "$powerTaskPath\PowerTask.psm1"
Write-Host "PowerTask Loaded Successfully" -ForegroundColor Green