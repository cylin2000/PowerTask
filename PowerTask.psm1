
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
        查询电影的豆瓣评�?
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

    $xml = (new-object net.webclient).downloadstring('https://raw.githubusercontent.com/cylin2000/powertask/master/softwares.xml?t='+(Get-Random))
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
        Write-Progress -Activity 'Downloading file ' -Status $url
        $client.DownloadFileAsync($url, $localFile)
    
        while (!($Global:downloadComplete)) {                
            $pc = $Global:DPCEventArgs.ProgressPercentage
            if ($pc -ne $null) {
                Write-Progress -Activity 'Downloading file ' -Status $url -PercentComplete $pc
            }
        }
    
        Write-Progress -Activity 'Downloading file ' -Status $url -Complete
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
        $xml = (new-object net.webclient).downloadstring('https://raw.githubusercontent.com/cylin2000/powertask/master/softwares.xml?t='+(Get-Random))
        $xmlDoc = [xml]$xml
        Write-Host "Please use following command to install software"
        foreach($node in $xmlDoc.SelectNodes("config/softwares/software")){
            $SoftwareName = $node.name
            Write-Host "    install $SoftwareName"
        }
        return ""
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
Export-ModuleMember "*-*"
