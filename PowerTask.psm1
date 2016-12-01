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

Export-ModuleMember "*-*"