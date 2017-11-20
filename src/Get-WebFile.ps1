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
        Write-Progress -Activity 'Downloading file ' -Status $url
        $client.DownloadFileAsync($url, $localFile)
    
        while (!($Global:downloadComplete)) {                
            $pc = $Global:DPCEventArgs.ProgressPercentage
            if ($pc -ne $null) {
                Write-Progress -Activity 'Downloading file ' -Status $url -PercentComplete $pc
            }
        }
    
        Write-Progress -Activity 'Downloading file ' -Status $url -Complete
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