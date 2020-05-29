
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
        # Get Relative Path
        $relPath = [system.io.path]::GetFullPath($item.FullName).SubString([system.io.path]::GetFullPath($Source).Length)        
        # Create Target Directories on FTP server
        if ($item.Attributes -eq "Directory"){
            try{
                Write-Host Creating FTP directory $item.Name                
                $makeDirectory = [System.Net.WebRequest]::Create($Target+$relPath);
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
        # Upload File  
        "Uploading "+$relPath+"... ["+$item.Length+" Bytes]"
        $uri = New-Object System.Uri($Target+$relPath)
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
	
	$length = [math]::Round($length/1MB, 2)
	
	Write-Host `n Uploaded $length Megabytes to $Target.
	Write-Host Copied $files files and created $directories directories.
}


function Compress-Zip {
    
    <#
    .SYNOPSIS
        Compress files to a zip package
    .DESCRIPTION 
        This task will compress files to a single zip package
    .EXAMPLE     
        Compress-Zip c:\source c:\target.zip
    #>
    
    Param(
      [Parameter(Mandatory=$True,HelpMessage="Enter Source Path")][string]$Path,
      [Parameter(HelpMessage="Enter Destination FileName")][string]$Destination
    )
    
    if(!$Destination) {
        $zipfile = $Path + ".zip"
    }     
    else {
        $zipfile = $Destination
    }

    if(!(Test-Path($zipfile))) {
        set-content $zipfile ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18))
        (dir $zipfile).IsReadOnly = $false
    }

    $shellApplication = new-object -com shell.application
    $zipPackage = $shellApplication.NameSpace($zipfile)

    dir $Path | foreach-object {           
        $zipPackage.CopyHere(($_.FullName));
        Start-sleep -milliseconds 500
    }
}

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

function Expand-Zip {
    <#
    .SYNOPSIS    
        Extract files from a zip package
    .DESCRIPTION 
        This task will extract files from a single zip package
    .EXAMPLE     
        Expand-Zip -ZipFileName c:\zipfile.zip -Destination c:\targetfolder
    .EXAMPLE
        Expand-Zip c:\zipfile.zip c:\targetfolder
    #>

    Param(
      [Parameter(Mandatory=$True,HelpMessage="Enter Zip FileName")][string]$ZipFileName,
      [Parameter(Mandatory=$True,HelpMessage="Enter Destination Path")][string]$Destination
    )
     
    if(Test-Path($ZipFileName))
    {   
        $shellApplication = new-object -com shell.application
        $zipPackage = $shellApplication.NameSpace($ZipFileName)
        if(!(Test-Path($destination))){
            $d = New-Item -Path $destination -Type Directory
            Write-Host "Creating Folder "$d.FullName
        }
        $destinationFolder = $shellApplication.NameSpace($destination)
        Write-Host "Extracting "$ZipFileName" to "$destination

        #CopyHere parameter definition please refer http://msdn.microsoft.com/en-us/library/bb787866(VS.85).aspx
        #16:Respond with "Yes to All" for any dialog box that is displayed. It will overwrite the existing files
        $destinationFolder.CopyHere($zipPackage.Items(),16)
    }
}

function Get-DoubanMovieRate {
    <#
    .SYNOPSIS    
        查询电影的豆瓣评分
    .DESCRIPTION 
        This task will extract files from a single zip package
    .EXAMPLE     
        Get-DoubanMovieRate '盗梦空间'
    #>

    param(
        [Parameter(Mandatory=$True)][String] $name
    )
    
    $wc = New-Object System.Net.WebClient
    $wc.Encoding = [System.Text.Encoding]::UTF8
    $jsonString = $wc.DownloadString("http://api.douban.com/v2/movie/search?q=$name")
    $movie = $jsonString | ConvertFrom-Json
    return $movie.subjects[0].rating.average
}

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

function Get-InstalledSoftware {
    
    <#
    .SYNOPSIS
        Get Installed Softwares on this computer
    .DESCRIPTION
        This function will return the Installed Software list according the registry
    .EXAMPLE
        Get-InstalledSoftware
    #>
    
    $InstalledSoftware = Get-ChildItem HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ | Get-ItemProperty
    IF (Test-path HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\){
        $InstalledSoftware += Get-ChildItem HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\ | Get-ItemProperty
    }
    IF (Test-path HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\) {
        $InstalledSoftware += Get-ChildItem HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ | Get-ItemProperty
    }
    #($InstalledSoftware | Where {$_.DisplayName -ne $Null -AND $_.SystemComponent -ne "1" -AND $_.ParentKeyName -eq $Null} |Select DisplayName).GetEnumerator() | Sort-Object {"$_"}
    $list = $InstalledSoftware | Where {$_.DisplayName -ne $Null -AND $_.SystemComponent -ne "1" }
    return $list
    # if($list -ne  $Null){
    #     $list|Select DisplayName,ParentDisplayName|Sort-Object {"$_"}
    # }
}

function Get-Software{
    
    <#
    .SYNOPSIS    
        Get Software from public.caiyunlin.com
    .DESCRIPTION 
        Get Software from public.caiyunlin.com
    .EXAMPLE     
        Get-Software
    .EXAMPLE
        Get-Software '7zip'
    #>

    param(
        [Parameter(Mandatory=$False)][String] $Name,
        [Parameter(Mandatory=$False)][String] $LocalPath
    )
    $webClient = new-object net.webclient;
    $webClient.Encoding = [System.Text.Encoding]::UTF8;
    $xml = $webClient.downloadstring('http://www.soft263.com/dev/PowerTask/softwares.xml?t='+(Get-Random))
    $xmlDoc = [xml]$xml

    if($Name -ne ""){
        Write-Host "Getting $Name"
        $baseUrl = $xmlDoc.SelectSingleNode("config/baseurl").InnerText
        $found = $False
        foreach($node in $xmlDoc.SelectNodes("config/softwares/software")){
            if($node.name -eq $Name){
                $found = $true
                $url = $baseUrl+$node.file
                if($LocalPath -eq ""){
                    $LocalPath = (Join-Path $pwd.Path $url.SubString($url.LastIndexOf('/')))
                }
                Get-WebFile $url $LocalPath

                Write-Host "File saved to $LocalPath"
            }
        }

        if(!$found){
            Write-Host "Can't find software $Name"
        }
        return $LocalPath
    }
    else{
        Write-Host "Please use following command to get software"
        foreach($node in $xmlDoc.SelectNodes("config/softwares/software")){
            $SoftwareName = $node.name
            Write-Host "    get $SoftwareName"
        }
        return ""
    }
}

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
    return $StringBuilder.ToString() 
}

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
        $now = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        Write-Verbose "Start Time $now"
        Write-Progress -Activity 'Downloading file ' -Status $url
        $client.DownloadFileAsync($url, $localFile)
    
        while (!($Global:downloadComplete)) {                
            $pc = $Global:DPCEventArgs.ProgressPercentage
            if ($null -ne $pc) {
                Write-Progress -Activity 'Downloading file ' -Status $url -PercentComplete $pc
            }
        }
    
        Write-Progress -Activity 'Downloading file ' -Status $url -Complete
        Write-Verbose "Downloded file $url"
        $now = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        Write-Verbose "End Time $now"
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

function Install-PowerTask{
    
    <#
    .SYNOPSIS    
        Install Latest PowerTask
    .DESCRIPTION 
        Install Latest PowerTask
    .EXAMPLE     
        Install-PowerTask
    #>
    Param (
        [Parameter(Mandatory=$False)][switch] $Force
    )
    if($Force){
        # 寮哄埗鏇存柊
        Write-Host "Get Lastest PowerTask"
        $powerTaskPath = "$env:USERPROFILE\PowerTask"
        $t = Get-Random
        $wc = New-Object System.Net.WebClient
        $wc.Encoding = [System.Text.Encoding]::UTF8
        $wc.DownloadFile("https://raw.githubusercontent.com/cylin2000/powertask/master/PowerTask.psm1?t=$t","$powerTaskPath\PowerTask.psm1")
    }
    $profile = "C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1"
    Write-Host "Installing PowerTask to profile" -ForegroundColor Green
    Set-Content $profile '$powerTaskPath = "$env:USERPROFILE\PowerTask"'
    Add-Content $profile 'Write-Host "Loading Local PowerTask ..." -ForegroundColor Green'
    Add-Content $profile 'Import-Module "$powerTaskPath\PowerTask.psm1" -Force'
    Add-Content $profile 'Get-Command -Module PowerTask'
    Add-Content $profile 'Write-Host "PowerTask Loaded Successfully" -ForegroundColor Green'

    if($Force){
        Import-Module "$powerTaskPath\PowerTask.psm1" -Force
        Get-Command -Module PowerTask
    }

    Write-Host "PowerTask Installed Successfully" -ForegroundColor Green
}

function Install-Software{
    
    <#
    .SYNOPSIS
        Download and Install Software into computer from Web 
    .DESCRIPTION
        This function will Download and Install Software into computer from a URL, if it's a green software, you could use it directly. If it's a install package, you need install it manually
    .EXAMPLE
        Install-Software 'putty' c:\users\Administrator\Desktop\putty
    .NOTES
        Copied from http://poshcode.org/2461
    #>
   
    

    param(
        [Parameter(Mandatory=$False)][String] $Name,
        [Parameter(Mandatory=$False)][String] $InstallPath
    )

    if($Name -ne ""){
        $LocalFile = Get-Software $Name
        if($LocalFile -ne ""){
            if($InstallPath -eq ""){
                $InstallPath = $Name
            }
            Expand-Zip $LocalFile $InstallPath
            Write-Host "Removing $LocalFile"
            Remove-Item $LocalFile
        }
    }
    else{
        $webClient = new-object net.webclient;
        $webClient.Encoding = [System.Text.Encoding]::UTF8;
        $xml = $webClient.downloadstring('http://www.soft263.com/dev/PowerTask/softwares.xml?t='+(Get-Random))
        $xmlDoc = [xml]$xml
        Write-Host "Please use following command to install software"
        foreach($node in $xmlDoc.SelectNodes("config/softwares/software")){
            $SoftwareName = $node.name
            Write-Host "    install $SoftwareName"
        }
        return ""
    }
}

function Invoke-Batch{
    <#
    .SYNOPSIS    
        Execute External Command
    .DESCRIPTION 
        This task will execute external bat command 
    .EXAMPLE     
        Invoke-Batch -Path "c:\test.bat arg1 arg2 arg3"
    .EXAMPLE
        Invoke-Batch -Path "c:\commands\*.bat"
    .EXAMPLE
        Invoke-Batch "C:\commands\*.bat"
    .NOTES       
        Please keep above information
    #>

    Param(
    [Parameter(Mandatory=$True,HelpMessage="File Path")][string]$Path,
    [Parameter(HelpMessage="Parameter String")]$ParamStr
    )

    if(Test-Path($Path)){ 
        Get-ChildItem $Path | foreach-object{
            $File = $_.FullName
            $tempFile = $env:tmp+"\temp.bat"
            $Command = """"+$File+""""+" "+$ParamStr
            Set-Content -Path $tempFile -Value $Command
            type $tempFile #display the command
            $filePath = Split-Path -Parent $File
            push-location $filePath #use bat file location to execute bat file
            Invoke-Expression -Command $tempFile
            pop-location
        }
    }
    else{                  #msiexec.exe/btstask.exe etc
        $File = $Path
        $tempFile = $env:tmp+"\temp.bat"
        $Command = """"+$File+""""+" "+$ParamStr
        Set-Content -Path $tempFile -Value $Command
        type $tempFile #display the command
        Invoke-Expression -Command $tempFile 
    }
}

function Invoke-FlashWindow {
    
    <#
        .SYSNOPSIS
            Flashes a window that has been hidden or minimized to the taskbar

        .DESCRIPTION
            Flashes a window that has been hidden or minimized to the taskbar

        .PARAMETER MainWindowHandle
            Handle of the window that will be set to flash

        .PARAMETER FlashRate
            The rate at which the window is to be flashed, in milliseconds.

            Default value is: 0 (Default cursor blink rate)

        .PARAMETER FlashCount
            The number of times to flash the window.

            Default value is: 2147483647

        .NOTES
            Name: Invoke-FlashWindow
            Author: Boe Prox
            Created: 26 AUG 2013
            Version History
                1.0 -- 26 AUG 2013 -- Boe Prox
                    -Initial Creation

        .LINK
            http://pinvoke.net/default.aspx/user32/FlashWindowEx.html
            http://msdn.microsoft.com/en-us/library/windows/desktop/ms679347(v=vs.85).aspx

        .EXAMPLE
            Start-Sleep -Seconds 5; Get-Process -Id $PID | Invoke-FlashWindow
            #Minimize or take focus off of console
 
            Description
            -----------
            PowerShell console taskbar window will begin flashing. This will only work if the focus is taken
            off of the console, or it is minimized.

        .EXAMPLE
            Invoke-FlashWindow -MainWindowHandle 565298 -FlashRate 150 -FlashCount 10

            Description
            -----------
            Flashes the window of handle 565298 for a total of 10 cycles while blinking every 150 milliseconds.
    #>
    [cmdletbinding()]
    Param (
        [parameter(ValueFromPipeline=$True,ValueFromPipeLineByPropertyName=$True)]
        [intptr]$MainWindowHandle,
        [parameter()]
        [int]$FlashRate = 0,
        [parameter()]
        [int]$FlashCount = ([int]::MaxValue)
    )
    Begin {        
        Try {
            $null = [Window]
        } Catch {
            Add-Type -TypeDefinition @"
            using System;
            using System.Collections.Generic;
            using System.Text;
            using System.Runtime.InteropServices;

            public class Window
            {
                [StructLayout(LayoutKind.Sequential)]
                public struct FLASHWINFO
                {
                    public UInt32 cbSize;
                    public IntPtr hwnd;
                    public UInt32 dwFlags;
                    public UInt32 uCount;
                    public UInt32 dwTimeout;
                }

                //Stop flashing. The system restores the window to its original state. 
                const UInt32 FLASHW_STOP = 0;
                //Flash the window caption. 
                const UInt32 FLASHW_CAPTION = 1;
                //Flash the taskbar button. 
                const UInt32 FLASHW_TRAY = 2;
                //Flash both the window caption and taskbar button.
                //This is equivalent to setting the FLASHW_CAPTION | FLASHW_TRAY flags. 
                const UInt32 FLASHW_ALL = 3;
                //Flash continuously, until the FLASHW_STOP flag is set. 
                const UInt32 FLASHW_TIMER = 4;
                //Flash continuously until the window comes to the foreground. 
                const UInt32 FLASHW_TIMERNOFG = 12; 


                [DllImport("user32.dll")]
                [return: MarshalAs(UnmanagedType.Bool)]
                static extern bool FlashWindowEx(ref FLASHWINFO pwfi);

                public static bool FlashWindow(IntPtr handle, UInt32 timeout, UInt32 count)
                {
                    IntPtr hWnd = handle;
                    FLASHWINFO fInfo = new FLASHWINFO();

                    fInfo.cbSize = Convert.ToUInt32(Marshal.SizeOf(fInfo));
                    fInfo.hwnd = hWnd;
                    fInfo.dwFlags = FLASHW_ALL | FLASHW_TIMERNOFG;
                    fInfo.uCount = count;
                    fInfo.dwTimeout = timeout;

                    return FlashWindowEx(ref fInfo);
                }
            }
"@
        }
    }
    Process {
        ForEach ($handle in $MainWindowHandle) {
            Write-Verbose ("Flashing window: {0}" -f $handle)
            $null = [Window]::FlashWindow($handle,$FlashRate,$FlashCount)
        }
    }
}

function Invoke-Sql {
    
    <#
    .SYNOPSIS
        Invoke a SQL command
    .DESCRIPTION 
        This task execute a SQL command
    .EXAMPLE     
        Invoke-Sql 'Server=localhost;Database=MY_DB;Integrated Security=True' 'select * from TestTable'
    #>

    Param (
        [Parameter(Mandatory=$True)][String] $ConnectionString,
        [Parameter(Mandatory=$True)][String] $Sql
    )

    $Connection = new-object system.data.SqlClient.SqlConnection($ConnectionString);
    $dataSet = new-object "System.Data.DataSet" "MyDataSet"
    $dataAdapter = new-object "System.Data.SqlClient.SqlDataAdapter" ($Sql, $Connection)
    $dataAdapter.Fill($dataSet) | Out-Null
    $Connection.Close()
    return $dataSet
}

function New-RandomPassword {
    <#
    .Synopsis
       Generates one or more complex passwords designed to fulfill the requirements for Active Directory
    .DESCRIPTION
       Generates one or more complex passwords designed to fulfill the requirements for Active Directory
    .EXAMPLE
       New-RandomPassword
       C&3SX6Kn

       Will generate one password with a length between 8  and 12 chars.
    .EXAMPLE
       New-RandomPassword -MinPasswordLength 8 -MaxPasswordLength 12 -Count 4
       7d&5cnaB
       !Bh776T"Fw
       9"C"RxKcY
       %mtM7#9LQ9h

       Will generate four passwords, each with a length of between 8 and 12 chars.
    .EXAMPLE
       New-RandomPassword -InputStrings abc, ABC, 123 -PasswordLength 4
       3ABa

       Generates a password with a length of 4 containing atleast one char from each InputString
    .EXAMPLE
       New-RandomPassword -InputStrings abc, ABC, 123 -PasswordLength 4 -FirstChar abcdefghijkmnpqrstuvwxyzABCEFGHJKLMNPQRSTUVWXYZ
       3ABa

       Generates a password with a length of 4 containing atleast one char from each InputString that will start with a letter from 
       the string specified with the parameter FirstChar
    .OUTPUTS
       [String]
    .NOTES
       Written by Simon Wåhlin, blog.simonw.se
       I take no responsibility for any issues caused by this script.
    .FUNCTIONALITY
       Generates random passwords
    .LINK
       http://blog.simonw.se/powershell-generating-random-password-for-active-directory/
       https://gallery.technet.microsoft.com/Generate-a-random-and-5c879ed5?ranMID=24542&ranEAID=je6NUbpObpQ&ranSiteID=je6NUbpObpQ-rxgkKd5_Wq03Oj0pmn0Igg&epi=je6NUbpObpQ-rxgkKd5_Wq03Oj0pmn0Igg&irgwc=1&OCID=AID681541_aff_7593_1243925&tduid=(ir__rjbrf320pkkfrlzaxmlij6lydu2xmetanq029osx00)(7593)(1243925)(je6NUbpObpQ-rxgkKd5_Wq03Oj0pmn0Igg)()&irclickid=_rjbrf320pkkfrlzaxmlij6lydu2xmetanq029osx00
   
    #>
    [CmdletBinding(DefaultParameterSetName='FixedLength',ConfirmImpact='None')]
    [OutputType([String])]
    Param
    (
        # Specifies minimum password length
        [Parameter(Mandatory=$false,
                   ParameterSetName='RandomLength')]
        [ValidateScript({$_ -gt 0})]
        [Alias('Min')] 
        [int]$MinPasswordLength = 8,
        
        # Specifies maximum password length
        [Parameter(Mandatory=$false,
                   ParameterSetName='RandomLength')]
        [ValidateScript({
                if($_ -ge $MinPasswordLength){$true}
                else{Throw 'Max value cannot be lesser than min value.'}})]
        [Alias('Max')]
        [int]$MaxPasswordLength = 12,

        # Specifies a fixed password length
        [Parameter(Mandatory=$false,
                   ParameterSetName='FixedLength')]
        [ValidateRange(1,2147483647)]
        [int]$PasswordLength = 8,
        
        # Specifies an array of strings containing charactergroups from which the password will be generated.
        # At least one char from each group (string) will be used.
        [String[]]$InputStrings = @('abcdefghijkmnpqrstuvwxyz', 'ABCEFGHJKLMNPQRSTUVWXYZ', '23456789', '!"#%&'),

        # Specifies a string containing a character group from which the first character in the password will be generated.
        # Useful for systems which requires first char in password to be alphabetic.
        [String] $FirstChar,
        
        # Specifies number of passwords to generate.
        [ValidateRange(1,2147483647)]
        [int]$Count = 1
    )
    Begin {
        Function Get-Seed{
            # Generate a seed for randomization
            $RandomBytes = New-Object -TypeName 'System.Byte[]' 4
            $Random = New-Object -TypeName 'System.Security.Cryptography.RNGCryptoServiceProvider'
            $Random.GetBytes($RandomBytes)
            [BitConverter]::ToUInt32($RandomBytes, 0)
        }
    }
    Process {
        For($iteration = 1;$iteration -le $Count; $iteration++){
            $Password = @{}
            # Create char arrays containing groups of possible chars
            [char[][]]$CharGroups = $InputStrings

            # Create char array containing all chars
            $AllChars = $CharGroups | ForEach-Object {[Char[]]$_}

            # Set password length
            if($PSCmdlet.ParameterSetName -eq 'RandomLength')
            {
                if($MinPasswordLength -eq $MaxPasswordLength) {
                    # If password length is set, use set length
                    $PasswordLength = $MinPasswordLength
                }
                else {
                    # Otherwise randomize password length
                    $PasswordLength = ((Get-Seed) % ($MaxPasswordLength + 1 - $MinPasswordLength)) + $MinPasswordLength
                }
            }

            # If FirstChar is defined, randomize first char in password from that string.
            if($PSBoundParameters.ContainsKey('FirstChar')){
                $Password.Add(0,$FirstChar[((Get-Seed) % $FirstChar.Length)])
            }
            # Randomize one char from each group
            Foreach($Group in $CharGroups) {
                if($Password.Count -lt $PasswordLength) {
                    $Index = Get-Seed
                    While ($Password.ContainsKey($Index)){
                        $Index = Get-Seed                        
                    }
                    $Password.Add($Index,$Group[((Get-Seed) % $Group.Count)])
                }
            }

            # Fill out with chars from $AllChars
            for($i=$Password.Count;$i -lt $PasswordLength;$i++) {
                $Index = Get-Seed
                While ($Password.ContainsKey($Index)){
                    $Index = Get-Seed                        
                }
                $Password.Add($Index,$AllChars[((Get-Seed) % $AllChars.Count)])
            }
            Write-Output -InputObject $(-join ($Password.GetEnumerator() | Sort-Object -Property Name | Select-Object -ExpandProperty Value))
        }
    }
}

function Send-Sms {
    <#
    .SYNOPSIS    
        Send SMS
    .DESCRIPTION 
        This task will send text message to mobile phone in China, you could request token from http://sms.webchinese.com.cn/
    .EXAMPLE     
        Send-Sms '13344445555' 'content' 'UID' 'TOKEN' '签名'
    .NOTES       
        短信发送后返回值    说　明
                    -1  没有该用户账户
                    -2  接口密钥不正确 [查看密钥] 不是账户登陆密码
                    -21 MD5接口密钥加密不正确
                    -3  短信数量不足
                    -11 该用户被禁用
                    -14 短信内容出现非法字符
                    -4  手机号格式不正确
                    -41 手机号码为空
                    -42 短信内容为空
                    -51 短信签名格式不正确 接口签名格式为：【签名内容】
                    -6  IP限制
                    大于0 短信发送数量
    #>

    Param(
      [Parameter(Mandatory=$True,HelpMessage="Mobile")][string]$Mobile,
      [Parameter(Mandatory=$True,HelpMessage="Text")][string]$Text,
      [Parameter(Mandatory=$True,HelpMessage="Uid")][string]$Uid,
      [Parameter(Mandatory=$True,HelpMessage="Token")][string]$Token,
      [Parameter(Mandatory=$False,HelpMessage="Signature")][string]$Signature
    )
     
    $ApiUrl = "http://utf8.sms.webchinese.cn/?Uid={2}&Key={3}&smsMob={0}&smsText={1}"

    Add-Type -AssemblyName System.Web

    if ( $Signature -ne '' ) {
        $Text = "$Text 【$Signature】"
    }
    
    $encodedText = [System.Web.HttpUtility]::UrlEncode($text)
    $url = [string]::Format($ApiUrl,$mobile,$encodedText,$Uid,$Token)
    $wc = New-Object System.Net.WebClient
    $result = $wc.DownloadString($url)
    return $result

}

function Set-TaskbarProgress{
    [cmdletbinding()]
    Param (
        [parameter(ValueFromPipeline=$True,ValueFromPipeLineByPropertyName=$True)]
        [intptr]$MainWindowHandle,
        [parameter()]
        [int]$ProgressValue = 10,
        [parameter()]
        [int]$ProgressMax = 100
    )
    Begin {        
        Try {
            $null = [Taskbar]
        } Catch {
            Add-Type -TypeDefinition @"
            using System;
            using System.Runtime.InteropServices;

            public class Taskbar
            {
                public enum TaskbarStates
                {
                    NoProgress    = 0,
                    Indeterminate = 0x1,
                    Normal        = 0x2,
                    Error         = 0x4,
                    Paused        = 0x8
                }

                [ComImportAttribute()]
                [GuidAttribute("ea1afb91-9e28-4b86-90e9-9e9f8a5eefaf")]
                [InterfaceTypeAttribute(ComInterfaceType.InterfaceIsIUnknown)]
                private interface ITaskbarList3
                {
                    // ITaskbarList
                    [PreserveSig]
                    void HrInit();
                    [PreserveSig]
                    void AddTab(IntPtr hwnd);
                    [PreserveSig]
                    void DeleteTab(IntPtr hwnd);
                    [PreserveSig]
                    void ActivateTab(IntPtr hwnd);
                    [PreserveSig]
                    void SetActiveAlt(IntPtr hwnd);

                    // ITaskbarList2
                    [PreserveSig]
                    void MarkFullscreenWindow(IntPtr hwnd, [MarshalAs(UnmanagedType.Bool)] bool fFullscreen);

                    // ITaskbarList3
                    [PreserveSig]
                    void SetProgressValue(IntPtr hwnd, UInt64 ullCompleted, UInt64 ullTotal);
                    [PreserveSig]
                    void SetProgressState(IntPtr hwnd, TaskbarStates state);
                }

                [GuidAttribute("56FDF344-FD6D-11d0-958A-006097C9A090")]
                [ClassInterfaceAttribute(ClassInterfaceType.None)]
                [ComImportAttribute()]
                private class TaskbarInstance
                {
                }

                private static ITaskbarList3 taskbarInstance = (ITaskbarList3)new TaskbarInstance();
                private static bool taskbarSupported = Environment.OSVersion.Version >= new Version(6, 1);

                public static void SetState(IntPtr windowHandle, TaskbarStates taskbarState)
                {
                    if (taskbarSupported) taskbarInstance.SetProgressState(windowHandle, taskbarState);
                }

                public static void SetValue(IntPtr windowHandle, double progressValue, double progressMax)
                {
                    if (taskbarSupported) taskbarInstance.SetProgressValue(windowHandle, (ulong)progressValue, (ulong)progressMax);
                }
            }
"@
        }
    }
    Process {
        ForEach ($handle in $MainWindowHandle) {
            Write-Verbose ("Set Taskbar Progress: {0}" -f $handle)
            $null = [Taskbar]::SetValue($handle,$ProgressValue,$ProgressMax)
        }
    }
}

function Show-BalloonTip {
    [CmdletBinding()] 
    Param (
        [Parameter(Mandatory=$true)]$Text,
        [Parameter(Mandatory=$true)]$Title,
        $Icon = 'Info',
        $Timeout = $10000
        )
    Process {
        Add-Type -AssemblyName System.Windows.Forms
        If ($PopUp -eq $null)  {
            $PopUp = New-Object System.Windows.Forms.NotifyIcon
        }
        $Path = Get-Process -Id $PID | Select-Object -ExpandProperty Path
        $PopUp.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($Path)
        $PopUp.BalloonTipIcon = $Icon
        $PopUp.BalloonTipText = $Text
        $PopUp.BalloonTipTitle = $Title
        $PopUp.Visible = $true
        $PopUp.ShowBalloonTip($Timeout)
    }
}

set-alias get               Get-Software                 -Scope Global
set-alias install           Install-Software             -Scope Global
set-alias md5               ConvertTo-MD5                -Scope Global
set-alias base64            ConvertTo-BASE64             -Scope Global
set-alias frombase64        ConvertFrom-BASE64           -Scope Global
Export-ModuleMember "*-*"
