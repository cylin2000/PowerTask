function Compress-Zip {
    <#
    .SYNOPSIS
        Zip files to a package
    .DESCRIPTION 
        This task will zip files to a single package
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

    if(!(test-path($zipfile))) {
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
    Param(
        [string]$zipfilename, 
        [string]$destination
    )

    if(test-path($zipfilename))
    {   
        $shellApplication = new-object -com shell.application
        $zipPackage = $shellApplication.NameSpace($zipfilename)
        $destinationFolder = $shellApplication.NameSpace($destination)
        $destinationFolder.CopyHere($zipPackage.Items())
    }
}

Export-ModuleMember "*-*"