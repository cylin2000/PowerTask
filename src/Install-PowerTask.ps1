function Install-PowerTask{
    
    <#
    .SYNOPSIS    
        Install Latest PowerTask
    .DESCRIPTION 
        Install Latest PowerTask
    .EXAMPLE     
        Install-PowerTask
    #>

    $powerTaskPath = "$env:USERPROFILE\PowerTask"
    Write-Host "Get Latest PowerTask"
    $t = Get-Random
    $wc = New-Object System.Net.WebClient
    $wc.Encoding = [System.Text.Encoding]::UTF8
    $wc.DownloadFile("https://raw.githubusercontent.com/cylin2000/powertask/master/PowerTask.psm1?t=$t","$powerTaskPath\PowerTask.psm1")
    
    Import-Module "$powerTaskPath\PowerTask.psm1" -Force
    Get-Command -Module PowerTask

    $profile = "C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1"
    Set-Content $profile '$powerTaskPath = "$env:USERPROFILE\PowerTask"'
    Add-Content $profile 'Write-Host "Loading Local PowerTask ..." -ForegroundColor Green'
    Add-Content $profile 'Import-Module "$powerTaskPath\PowerTask.psm1" -Force'
    Add-Content $profile 'Get-Command -Module PowerTask'
    Add-Content $profile 'Write-Host "PowerTask Loaded Successfully" -ForegroundColor Green'

    Write-Host "PowerTask Installed Successfully" -ForegroundColor Green
}
