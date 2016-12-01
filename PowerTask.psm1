function Compress-Zip {
    <#
    .SYNOPSIS
        Zip files to a package
    .DESCRIPTION 
        This task will zip files to a single package
    .EXAMPLE     
        Zip-File c:\source c:\target.zip
    #>
    Param(
      [Parameter(Mandatory=$True,HelpMessage="Enter Source Path")][string]$SourcePath,
      [Parameter(HelpMessage="Enter ZipFileName")][string]$ZipFileName
    )
    
    if(!$ZipFileName) {
        $zipfile = $Path + ".zip"
    }     
    else {
        $zipfile = $ZipFileName
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