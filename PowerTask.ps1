$powerTaskPath = "$env:USERPROFILE\PowerTask"
if(!(Test-Path $powerTaskPath)){ md $powerTaskPath | Out-Null }
Write-Host 
Write-Host "Loading Online PowerTask ..." -ForegroundColor Green
$t = Get-Random
$wc = New-Object System.Net.WebClient
$wc.Encoding = [System.Text.Encoding]::UTF8
$wc.DownloadFile("http://www.soft263.com/dev/PowerTask/PowerTask.psm1?t=$t","$powerTaskPath\PowerTask.psm1")
Import-Module "$powerTaskPath\PowerTask.psm1" -Force
Get-Command -Module PowerTask
Write-Host 
Write-Host "PowerTask Loaded Successfully" -ForegroundColor Green