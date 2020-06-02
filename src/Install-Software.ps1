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

    $webClient = new-object net.webclient;
    $webClient.Encoding = [System.Text.Encoding]::UTF8;
    $xml = $webClient.downloadstring("$powerTaskUrl/softwares.xml?t="+(Get-Random))
    $xmlDoc = [xml]$xml

    if($Name -ne ""){
        $baseUrl = $xmlDoc.SelectSingleNode("config/baseurl").InnerText
        $found = $False
        foreach($node in $xmlDoc.SelectNodes("config/softwares/software")){
            if($node.name -eq $Name){
                $found = $true
                $url = $baseUrl+$node.file
                if($LocalPath -eq ""){
                    $LocalPath = (Join-Path $cachePath $url.SubString($url.LastIndexOf('/')))
                }
                $run = $node.run
                Get-WebFile $url $LocalPath
                Write-Host "File saved to $LocalPath"
                if($InstallPath -eq ""){
                    $InstallPath = "$cachePath\$Name"
                }
                Expand-Zip $LocalPath $InstallPath
                Write-Host "Removing $LocalPath"
                Remove-Item $LocalPath
                # Start Install
                $installBatFile = "$InstallPath\run-install.bat"
                Set-Content $installBatFile $run
                Invoke-Batch $installBatFile
            }
        }

        if(!$found){
            Write-Host "Can't find software $Name"
        }
    }
    else{
        
        Write-Host "Please use following command to install software"
        foreach($node in $xmlDoc.SelectNodes("config/softwares/software")){
            $SoftwareName = $node.name
            Write-Host "    install $SoftwareName"
        }
        return ""
    }
}