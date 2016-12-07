function Compress-Zip {
    <#
    .SYNOPSIS
        Compress files to a zip package
    .DESCRIPTION 
        This task will compress files to a single zip package
    .EXAMPLE     
        Compress-Zip c:\source c:\target.zip
    #>
    
    Param(
      [Parameter(Mandatory=$True,HelpMessage="Enter Source Path")][string]$Path,
      [Parameter(HelpMessage="Enter Destination FileName")][string]$Destination
    )
    
    if(!$Destination) {
        $zipfile = $Path + ".zip"
    }     
    else {
        $zipfile = $Destination
    }

    if(!(Test-Path($zipfile))) {
        set-content $zipfile ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18))
        (dir $zipfile).IsReadOnly = $false
    }

    $shellApplication = new-object -com shell.application
    $zipPackage = $shellApplication.NameSpace($zipfile)

    dir $Path | foreach-object {           
        $zipPackage.CopyHere(($_.FullName));
        Start-sleep -milliseconds 500
    }
}

function Expand-Zip {
    <#
    .SYNOPSIS    
        Extract files from a zip package
    .DESCRIPTION 
        This task will extract files from a single zip package
    .EXAMPLE     
        Expand-Zip -ZipFileName c:\zipfile.zip -Destination c:\targetfolder
    .EXAMPLE
        Expand-Zip c:\zipfile.zip c:\targetfolder
    #>

    Param(
      [Parameter(Mandatory=$True,HelpMessage="Enter Zip FileName")][string]$ZipFileName,
      [Parameter(Mandatory=$True,HelpMessage="Enter Destination Path")][string]$Destination
    )
     
    if(Test-Path($ZipFileName))
    {   
        $shellApplication = new-object -com shell.application
        $zipPackage = $shellApplication.NameSpace($ZipFileName)
        if(!(Test-Path($destination))){
            $d = New-Item -Path $destination -Type Directory
            Write-Host "Creating Folder "$d.FullName
        }
        $destinationFolder = $shellApplication.NameSpace($destination)
        Write-Host "Extracting "$ZipFileName" to "$destination

        #CopyHere parameter definition please refer http://msdn.microsoft.com/en-us/library/bb787866(VS.85).aspx
        #16:Respond with "Yes to All" for any dialog box that is displayed. It will overwrite the existing files
        $destinationFolder.CopyHere($zipPackage.Items(),16)
    }
}

function Get-InstalledSoftware {
    <#
    .SYNOPSIS
        Get Installed Softwares on this computer
    .DESCRIPTION
        This function will return the Installed Software list
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

function Get-WebFile {
    <#
    .SYNOPSIS
        Get Installed Softwares on this computer
    .DESCRIPTION
        This function will return the Installed Software list
    .EXAMPLE
        Get-WebFile http://the.earth.li/~sgtatham/putty/0.67/x86/putty.zip c:/putty.zip
    .NOTES
        Copied from http://poshcode.org/2461
    #>
    param(
        [Parameter(Mandatory=$True)][String] $url,
        [Parameter(Mandatory=$False)][String] $localFile = (Join-Path $pwd.Path $url.SubString($url.LastIndexOf('/')))
    )

    begin {
        $client = New-Object System.Net.WebClient
        $Global:downloadComplete = $false
    
        $eventDataComplete = Register-ObjectEvent $client DownloadFileCompleted `
            -SourceIdentifier WebClient.DownloadFileComplete `
            -Action {$Global:downloadComplete = $true}
        $eventDataProgress = Register-ObjectEvent $client DownloadProgressChanged `
            -SourceIdentifier WebClient.DownloadProgressChanged `
            -Action { $Global:DPCEventArgs = $EventArgs }    
    }
    
    process {
        Write-Progress -Activity 'Downloading file' -Status $url
        $client.DownloadFileAsync($url, $localFile)
    
        while (!($Global:downloadComplete)) {                
            $pc = $Global:DPCEventArgs.ProgressPercentage
            if ($pc -ne $null) {
                Write-Progress -Activity 'Downloading file' -Status $url -PercentComplete $pc
            }
        }
    
        Write-Progress -Activity 'Downloading file' -Status $url -Complete
    }
    
    end {
        Unregister-Event -SourceIdentifier WebClient.DownloadProgressChanged
        Unregister-Event -SourceIdentifier WebClient.DownloadFileComplete
        $client.Dispose()
        $Global:downloadComplete = $null
        $Global:DPCEventArgs = $null
        Remove-Variable client
        Remove-Variable eventDataComplete
        Remove-Variable eventDataProgress
        [GC]::Collect()    
    }
}

function Get-WebString {
    param(
        [Parameter(Mandatory=$True)][String] $url
    )
    
    $wc = New-Object System.Net.WebClient
    $wc.Encoding = [System.Text.Encoding]::UTF8
    return $wc.DownloadString();
}

Export-ModuleMember "*-*"