function Get-InstalledSoftware {
    
    <#
    .SYNOPSIS
        Get Installed Softwares on this computer
    .DESCRIPTION
        This function will return the Installed Software list according the registry
    .EXAMPLE
        Get-InstalledSoftware
    #>
    
    $InstalledSoftware = Get-ChildItem HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ | Get-ItemProperty
    IF (Test-path HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\){
        $InstalledSoftware += Get-ChildItem HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\ | Get-ItemProperty
    }
    IF (Test-path HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\) {
        $InstalledSoftware += Get-ChildItem HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ | Get-ItemProperty
    }
    #($InstalledSoftware | Where {$_.DisplayName -ne $Null -AND $_.SystemComponent -ne "1" -AND $_.ParentKeyName -eq $Null} |Select DisplayName).GetEnumerator() | Sort-Object {"$_"}
    $list = $InstalledSoftware | Where {$_.DisplayName -ne $Null -AND $_.SystemComponent -ne "1" }
    return $list
    # if($list -ne  $Null){
    #     $list|Select DisplayName,ParentDisplayName|Sort-Object {"$_"}
    # }
}