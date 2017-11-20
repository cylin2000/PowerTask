function Get-FtpFile{

    <#
    .SYNOPSIS    
        Get File From a FTP Server
    .DESCRIPTION 
        This task will download file from a FTP server, you must provide correct FTP uri and username & password information
    .EXAMPLE     
        Expand-Zip -ZipFileName c:\zipfile.zip -Destination c:\targetfolder
    .EXAMPLE
        Expand-Zip c:\zipfile.zip c:\targetfolder
    #>

    param(
        [Parameter(Mandatory=$True)][String] $Source,
        [Parameter(Mandatory=$True)][String] $UserName,
        [Parameter(Mandatory=$True)][String] $Password,
        [Parameter(Mandatory=$False)][String] $Target
    )

    $ftpRequest = [System.Net.FtpWebRequest]::create($Source) 
    $ftpRequest.Credentials = New-Object System.Net.NetworkCredential($UserName,$Password) 
    $ftpRequest.Method = [System.Net.WebRequestMethods+Ftp]::DownloadFile 
    $ftpRequest.UseBinary = $true 
    $ftpRequest.KeepAlive = $false 
      
    $ftpResponse = $ftpRequest.GetResponse() 
    $responseStream = $ftpResponse.GetResponseStream() 
      
    $targetFile = New-Object IO.FileStream ($Target,[IO.FileMode]::Create) 
    [byte[]]$readBuffer = New-Object byte[] 1024 
    
    do{ 
        $readLength = $responseStream.Read($readBuffer,0,1024) 
        $targetFile.Write($readBuffer,0,$readLength) 
    } 
    while ($readLength -ne 0) 
    $targetFile.close() 
}