function Show-BalloonTip {
    [CmdletBinding()] 
    Param (
        [Parameter(Mandatory=$true)]$Text,
        [Parameter(Mandatory=$true)]$Title,
        $Icon = 'Info',
        $Timeout = $10000
        )
    Process {
        Add-Type -AssemblyName System.Windows.Forms
        If ($PopUp -eq $null)  {
            $PopUp = New-Object System.Windows.Forms.NotifyIcon
        }
        $Path = Get-Process -Id $PID | Select-Object -ExpandProperty Path
        $PopUp.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($Path)
        $PopUp.BalloonTipIcon = $Icon
        $PopUp.BalloonTipText = $Text
        $PopUp.BalloonTipTitle = $Title
        $PopUp.Visible = $true
        $PopUp.ShowBalloonTip($Timeout)
    }
}