function Add-FtpFile{
    
    <#
    .SYNOPSIS
        Upload a File to FTP Server
    .DESCRIPTION 
        This task will Upload a File to FTP Server
    .EXAMPLE     
        Add-FtpFile "c:\temp" 'ftpuser' 'password' 'ftp://ftpserver.com/path/folders/'
    #>

    param(
        [Parameter(Mandatory=$True)][String] $Source,
        [Parameter(Mandatory=$True)][String] $UserName,
        [Parameter(Mandatory=$True)][String] $Password,
        [Parameter(Mandatory=$True)][String] $Target
    )

    $webclient = New-Object System.Net.WebClient 
    $credentials = New-Object System.Net.NetworkCredential($UserName,$Password)
    $webclient.Credentials = $credentials
	
	$length = 0
	$files = 0
	$directories = 0
	
    foreach($item in Get-ChildItem -recurse $Source){ 
        $realPath = [system.io.path]::GetFullPath($item.FullName).SubString([system.io.path]::GetFullPath($Source).Length)
        if ($item.Attributes -eq "Directory"){
            try{
                Write-Host Creating FTP directory $item.Name                
                $makeDirectory = [System.Net.WebRequest]::Create($Target+$realPath);
                $makeDirectory.Credentials = $credentials
                $makeDirectory.Method = [System.Net.WebRequestMethods+FTP]::MakeDirectory;
                $makeDirectory.GetResponse();
				
				$directories = $directories + 1
            
            }catch [Net.WebException] {
                Write-Host FTP $item.Name already exists.
				$directories = $directories - 1
            }

            continue;
        }
        
        if($realPath -ne ''){
            "Uploading "+$realPath+"... ["+$item.Length+" Bytes]"
            $uri = New-Object System.Uri($Target+$realPath)
            try {
                $webclient.UploadFile($uri, $item.FullName)
                Write-Host File $item uploaded`n
                $length = $length + $item.Length
                $files = $files + 1
            } catch [Net.WebException] {
                Write-Host FAILURE! There was an issue uploading the file $item
                Write-Host $_
            }
        }
    }
	
	$length = [math]::Round($length/1MB, 2)
	
	Write-Host `n Uploaded $length Megabytes to $Target.
	Write-Host Copied $files files and created $directories directories.
}