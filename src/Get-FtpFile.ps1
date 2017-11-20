function Get-FtpFile{

    <#
    .SYNOPSIS    
        Get File From a FTP Server
    .DESCRIPTION 
        This task will download file from a FTP server, you must provide correct FTP uri and username & password information
    .EXAMPLE     
        Get-FtpFile 'ftp://ftpserver.com/path/myfile.zip' 'ftpuser' 'password' 'c:/myfile.zip'
    .EXAMPLE
        Get-FtpFile 'ftp://ftpserver.com/path/folders/' 'ftpuser' 'password' 'c:/folders'
    #>

    param(
        [Parameter(Mandatory=$True)][String] $Source,
        [Parameter(Mandatory=$True)][String] $UserName,
        [Parameter(Mandatory=$True)][String] $Password,
        [Parameter(Mandatory=$False)][String] $Target
    )

    $credentials = New-Object System.Net.NetworkCredential($UserName,$Password) 

    function DownloadFtpDirectory($url, $credentials, $localPath){
        $listRequest = [Net.WebRequest]::Create($url)
        $listRequest.Method = [System.Net.WebRequestMethods+FTP]::ListDirectoryDetails
        $listRequest.Credentials = $credentials

        $lines = New-Object System.Collections.ArrayList

        $listResponse = $listRequest.GetResponse()
        $listStream = $listResponse.GetResponseStream()
        $listReader = New-Object System.IO.StreamReader($listStream)
        while (!$listReader.EndOfStream)
        {
            $line = $listReader.ReadLine()
            $lines.Add($line) | Out-Null
        }
        $listReader.Dispose()
        $listStream.Dispose()
        $listResponse.Dispose()

        foreach ($line in $lines)
        {
            $tokens = $line.Split(" ", 9, [StringSplitOptions]::RemoveEmptyEntries)
            $name = $tokens[8]
            $permissions = $tokens[0]

            $localFilePath = Join-Path $localPath $name
            $fileUrl = ($url + $name)

            if ($permissions[0] -eq 'd')
            {
                if (!(Test-Path $localFilePath -PathType container))
                {
                    Write-Host "Creating directory $localFilePath"
                    New-Item $localFilePath -Type directory | Out-Null
                }

                DownloadFtpDirectory ($fileUrl + "/") $credentials $localFilePath
            }
            else
            {
                Write-Host "Downloading $fileUrl to $localFilePath"

                $downloadRequest = [Net.WebRequest]::Create($fileUrl)
                $downloadRequest.Method = [System.Net.WebRequestMethods+FTP]::DownloadFile
                $downloadRequest.Credentials = $credentials

                $downloadResponse = $downloadRequest.GetResponse()
                $sourceStream = $downloadResponse.GetResponseStream()
                $targetStream = [System.IO.File]::Create($localFilePath)
                $buffer = New-Object byte[] 10240
                while (($read = $sourceStream.Read($buffer, 0, $buffer.Length)) -gt 0)
                {
                    $targetStream.Write($buffer, 0, $read);
                }
                $targetStream.Dispose()
                $sourceStream.Dispose()
                $downloadResponse.Dispose()
            }
        }
    }

    if($Source.EndsWith("/")){ # Download Folder
        if (!(Test-Path $Target -PathType container))
        {
            Write-Host "Creating directory $Target"
            New-Item $Target -Type directory | Out-Null
        }
        DownloadFtpDirectory $Source $credentials $Target
    }
    else{ # Download File
        $localFilePath = Split-Path -Parent $Target
        if (!(Test-Path $localFilePath -PathType container))
        {
            Write-Host "Creating directory $localFilePath"
            New-Item $localFilePath -Type directory | Out-Null
        }
        Write-Host "Downloading $Source to $Target"

        $ftpRequest = [System.Net.FtpWebRequest]::create($Source) 
        $ftpRequest.Credentials = $credentials 
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
}