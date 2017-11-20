function Set-FtpFile{
    
    <#
    .SYNOPSIS
        Upload a File to FTP Server
    .DESCRIPTION 
        This task will Upload a File to FTP Server
    .EXAMPLE     
        Set-FtpFile 
    #>

    param(
        [Parameter(Mandatory=$True)][String] $Source,
        [Parameter(Mandatory=$True)][String] $UserName,
        [Parameter(Mandatory=$True)][String] $Password,
        [Parameter(Mandatory=$True)][String] $Target
    )

    Write-Host 'Not Implemented'
}