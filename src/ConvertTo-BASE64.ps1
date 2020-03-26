function ConvertTo-BASE64 { 
    <#
    .SYNOPSIS
        Convert string to BASE64 format
    .DESCRIPTION
        Convert string to BASE64 format
    .EXAMPLE
        ConvertTo-BASE64 "abc" 
    #>

    param(
        [Parameter(Mandatory=$True)][String] $String
    )

    $byteArray = [System.Text.UnicodeEncoding]::Unicode.GetBytes($String)
    [Convert]::ToBase64String( $byteArray )
}