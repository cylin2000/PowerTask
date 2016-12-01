$powerTaskPath = "$env:USERPROFILE\PowerTask"
$wc = New-Object System.Net.WebClient
$wc.Encoding = [System.Text.Encoding]::UTF8
if(!(Test-Path $powerTaskPath)){
    md $powerTaskPath | Out-Null
}
$wc.DownloadFile("https://raw.githubusercontent.com/cylin2000/powertask/master/PowerTask.psm1","$powerTaskPath\PowerTask.psm1")
Import-Module "$powerTaskPath\PowerTask.psm1" -Force
Get-Command -Module PowerTask
Write-Host "PowerTask Loaded Successfully" -ForegroundColor Green