Write-Host "Building PowerTask..."

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$files = Get-ChildItem "$scriptPath\src"
$distFile = "$scriptPath\PowerTask.psm1"
Set-Content $distFile ""
foreach($file in $files){
    $fileName = $file.FullName
    Write-Host "Processing $fileName"
    $content = Get-Content $fileName
    Add-Content $distFile $content
    Add-Content $distFile ''
}

Add-Content $distFile 'set-alias get               Get-Software                 -Scope Global'
Add-Content $distFile 'set-alias install           Install-Software             -Scope Global'
Add-Content $distFile 'Export-ModuleMember "*-*"'

Write-Host "Complete!"