function Run-External{
    <#
    .SYNOPSIS    
        Execute External Command
    .DESCRIPTION 
        This task will execute external bat command 
    .EXAMPLE     
        RunExternal -Path "c:\test.bat arg1 arg2 arg3"
    .EXAMPLE
        RunExternal -Path "c:\commands\*.bat"
    .EXAMPLE
        RunExternal "C:\commands\*.bat"
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