function Get-WebContent {

    <#
    .SYNOPSIS    
        Get Web Content from a url
    .DESCRIPTION 
        It will return a string from a url
    .EXAMPLE     
        Get-WebContent http://www.bing.com
    #>

    param(
        [Parameter(Mandatory=$True)][String] $url
    )
    Add-Type -AssemblyName System.Web
    $wc = New-Object System.Net.WebClient
    $wc.Encoding = [System.Text.Encoding]::UTF8
    return $wc.DownloadString($url);
}