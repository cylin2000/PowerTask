Write-Host "Building PowerTask..."

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$files = Get-ChildItem "$scriptPath\src"
$distFile = "$scriptPath\PowerTask.psm1"
Set-Content $distFile "" -encoding UTF8
foreach($file in $files){
    if($file.Name -ne "Initialize-PowerTask.ps1"){
        $fileName = $file.FullName
        Write-Host "Processing $fileName"
        $content = Get-Content $fileName
        Add-Content $distFile $content
        Add-Content $distFile ''
        Start-Sleep 2
    }
}
Write-Host "Processing Initialize-PowerTask"
$content = Get-Content "$scriptPath\src\Initialize-PowerTask.ps1"
Add-Content $distFile $content


Write-Host "Complete!"