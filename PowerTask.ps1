$powerTaskPath = "$env:USERPROFILE\PowerTask"
if(!(Test-Path $powerTaskPath)){ md $powerTaskPath | Out-Null }
Write-Host 
Write-Host "Loading PowerTask ..." -ForegroundColor Green
if(!(Test-Path "$powerTaskPath\PowerTask.psm1")){
    $t = Get-Random
    $wc = New-Object System.Net.WebClient
    $wc.Encoding = [System.Text.Encoding]::UTF8
    $wc.DownloadFile("https://raw.githubusercontent.com/cylin2000/powertask/master/PowerTask.psm1?t=$t","$powerTaskPath\PowerTask.psm1")
}
Import-Module "$powerTaskPath\PowerTask.psm1" -Force
Get-Command -Module PowerTask
Write-Host 
Write-Host "PowerTask Loaded Successfully" -ForegroundColor Green