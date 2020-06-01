# PowerTask Entry 
$powerTaskUrl = "http://www.soft263.com/dev/PowerTask"
$powerTaskPath = "$env:USERPROFILE\PowerTask"
$cachePath = "$powerTaskPath\cache"
if(!(Test-Path $powerTaskPath)){ md $powerTaskPath | Out-Null }
if(!(Test-Path $cachePath)){ md $cachePath | Out-Null }

Write-Host 
Write-Host "Loading Online PowerTask ..." -ForegroundColor Green
$t = Get-Random
$wc = New-Object System.Net.WebClient
$wc.Encoding = [System.Text.Encoding]::UTF8
# download module
$wc.DownloadFile("$powerTaskUrl/PowerTask.psm1?t=$t","$powerTaskPath\PowerTask.psm1")
# download softwares
$wc.DownloadFile("$powerTaskUrl/softwares.xml?t=$t","$powerTaskPath\softwares.xml")

Import-Module "$powerTaskPath\PowerTask.psm1" -Force
Get-Command -Module PowerTask
Write-Host 
Write-Host "PowerTask Loaded Successfully" -ForegroundColor Green