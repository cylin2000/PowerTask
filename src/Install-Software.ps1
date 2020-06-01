function Install-Software{
    
    <#
    .SYNOPSIS
        Download and Install Software into computer from Web 
    .DESCRIPTION
        This function will Download and Install Software into computer from a URL, if it's a green software, you could use it directly. If it's a install package, you need install it manually
    .EXAMPLE
        Install-Software 'putty' c:\users\Administrator\Desktop\putty
    .NOTES
        Copied from http://poshcode.org/2461
    #>
   
    

    param(
        [Parameter(Mandatory=$False)][String] $Name,
        [Parameter(Mandatory=$False)][String] $InstallPath
    )

    if($Name -ne ""){
        $LocalFile = Get-Software $Name
        if($LocalFile -ne ""){
            if($InstallPath -eq ""){
                $InstallPath = $Name
            }
            Expand-Zip $LocalFile $InstallPath
            Write-Host "Removing $LocalFile"
            Remove-Item $LocalFile
            # Start Install
        }
    }
    else{
        $webClient = new-object net.webclient;
        $webClient.Encoding = [System.Text.Encoding]::UTF8;
        $xml = $webClient.downloadstring('http://www.soft263.com/dev/PowerTask/softwares.xml?t='+(Get-Random))
        $xmlDoc = [xml]$xml
        Write-Host "Please use following command to install software"
        foreach($node in $xmlDoc.SelectNodes("config/softwares/software")){
            $SoftwareName = $node.name
            Write-Host "    install $SoftwareName"
        }
        return ""
    }
}