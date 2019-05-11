function Install-PowerTask{
    
    <#
    .SYNOPSIS    
        Install Latest PowerTask
    .DESCRIPTION 
        Install Latest PowerTask
    .EXAMPLE     
        Install-PowerTask
    #>
    Param (
        [Parameter(Mandatory=$true)]$Force
    )
    if($Force){
        # 强制更新
        Write-Host "Get Lastest PowerTask"
        $powerTaskPath = "$env:USERPROFILE\PowerTask"
        $t = Get-Random
        $wc = New-Object System.Net.WebClient
        $wc.Encoding = [System.Text.Encoding]::UTF8
        $wc.DownloadFile("https://raw.githubusercontent.com/cylin2000/powertask/master/PowerTask.psm1?t=$t","$powerTaskPath\PowerTask.psm1")
    }
    $profile = "C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1"
    Write-Host "Installing PowerTask to profile" -ForegroundColor Green
    Set-Content $profile '$powerTaskPath = "$env:USERPROFILE\PowerTask"'
    Add-Content $profile 'Write-Host "Loading Local PowerTask ..." -ForegroundColor Green'
    Add-Content $profile 'Import-Module "$powerTaskPath\PowerTask.psm1" -Force'
    Add-Content $profile 'Get-Command -Module PowerTask'
    Add-Content $profile 'Write-Host "PowerTask Loaded Successfully" -ForegroundColor Green'

    if($Force){
        Import-Module "$powerTaskPath\PowerTask.psm1" -Force
        Get-Command -Module PowerTask
    }

    Write-Host "PowerTask Installed Successfully" -ForegroundColor Green
}
