function ConvertFrom-BASE64 { 
    <#
    .SYNOPSIS
        Convert string from BASE64 format
    .DESCRIPTION
        Convert string from BASE64 format
    .EXAMPLE
        ConvertFrom-BASE64 "YQBiAGMA" 
    #>

    param(
        [Parameter(Mandatory=$True)][String] $String
    )

    $byteArray = [Convert]::FromBase64String($String)
    [System.Text.UnicodeEncoding]::Unicode.GetString($byteArray)
    
}