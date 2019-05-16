function Get-Software{
    
    <#
    .SYNOPSIS    
        Get Software from public.caiyunlin.com
    .DESCRIPTION 
        Get Software from public.caiyunlin.com
    .EXAMPLE     
        Get-Software
    .EXAMPLE
        Get-Software '7zip'
    #>

    param(
        [Parameter(Mandatory=$False)][String] $Name,
        [Parameter(Mandatory=$False)][String] $LocalPath
    )
    $webClient = new-object net.webclient;
    $webClient.Encoding = [System.Text.Encoding]::UTF8;
    $xml = $webClient.downloadstring('https://raw.githubusercontent.com/cylin2000/powertask/master/softwares.xml?t='+(Get-Random))
    $xmlDoc = [xml]$xml

    if($Name -ne ""){
        Write-Host "Getting $Name"
        $baseUrl = $xmlDoc.SelectSingleNode("config/baseurl").InnerText
        $found = $False
        foreach($node in $xmlDoc.SelectNodes("config/softwares/software")){
            if($node.name -eq $Name){
                $found = $true
                $url = $baseUrl+$node.file
                if($LocalPath -eq ""){
                    $LocalPath = (Join-Path $pwd.Path $url.SubString($url.LastIndexOf('/')))
                }
                Get-WebFile $url $LocalPath

                Write-Host "File saved to $LocalPath"
            }
        }

        if(!$found){
            Write-Host "Can't find software $Name"
        }
        return $LocalPath
    }
    else{
        Write-Host "Please use following command to get software"
        foreach($node in $xmlDoc.SelectNodes("config/softwares/software")){
            $SoftwareName = $node.name
            Write-Host "    get $SoftwareName"
        }
        return ""
    }
}
