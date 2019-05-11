function Install-PowerTask{
    
    <#
    .SYNOPSIS    
        Install Latest PowerTask
    .DESCRIPTION 
        Install Latest PowerTask
    .EXAMPLE     
        Install-PowerTask
    #>

    $profile = "C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1"
    Write-Host "Installing PowerTask to profile" -ForegroundColor Green
    Set-Content $profile '$powerTaskPath = "$env:USERPROFILE\PowerTask"'
    Add-Content $profile 'Write-Host "Loading Local PowerTask ..." -ForegroundColor Green'
    Add-Content $profile 'Import-Module "$powerTaskPath\PowerTask.psm1" -Force'
    Add-Content $profile 'Get-Command -Module PowerTask'
    Add-Content $profile 'Write-Host "PowerTask Loaded Successfully" -ForegroundColor Green'
    Write-Host "PowerTask Installed Successfully" -ForegroundColor Green
}
