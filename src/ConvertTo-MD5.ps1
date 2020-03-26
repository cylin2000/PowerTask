function ConvertTo-MD5 { 
    <#
    .SYNOPSIS
        Convert string to MD5 format
    .DESCRIPTION
        Convert string to MD5 format
    .EXAMPLE
        ConvertTo-MD5 "abc" 
    #>

    param(
        [Parameter(Mandatory=$True)][String] $String
    )

    Get-StringHash $String "MD5"
}