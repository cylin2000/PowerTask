function Get-StringHash { 
    <#
    .SYNOPSIS
        Get String Hash
    .DESCRIPTION
        Get String Hash
    .EXAMPLE
        Get-StringHash "My String to hash" "MD5"
        Get-StringHash "My String to hash" "RIPEMD160"
        Get-StringHash "My String to hash" "SHA1"
        Get-StringHash "My String to hash" "SHA256"
        Get-StringHash "My String to hash" "SHA384"
        Get-StringHash "My String to hash" "SHA512"
    .NOTES
        from https://gallery.technet.microsoft.com/scriptcenter/Get-StringHash-aa843f71
    #>

    param(
        [Parameter(Mandatory=$True)][String] $String,
        [Parameter(Mandatory=$False)][String] $HashName = "MD5"
    )

    $StringBuilder = New-Object System.Text.StringBuilder 
    [System.Security.Cryptography.HashAlgorithm]::Create($HashName).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String))|%{ 
    [Void]$StringBuilder.Append($_.ToString("x2")) 
    } 
    $StringBuilder.ToString() 
}