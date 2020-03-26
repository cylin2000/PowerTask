Write-Host "Building PowerTask..."

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$files = Get-ChildItem "$scriptPath\src"
$distFile = "$scriptPath\PowerTask.psm1"
Set-Content $distFile "" -encoding UTF8
foreach($file in $files){
    $fileName = $file.FullName
    Write-Host "Processing $fileName"
    $content = Get-Content $fileName
    Add-Content $distFile $content
    Add-Content $distFile ''
    Start-Sleep 2
}
# TODO: need fix Add-Content locks file during processing
Add-Content $distFile 'set-alias get               Get-Software                 -Scope Global'
Add-Content $distFile 'set-alias install           Install-Software             -Scope Global'
Add-Content $distFile 'set-alias md5               ConvertTo-MD5                -Scope Global'
Add-Content $distFile 'set-alias base64            ConvertTo-BASE64             -Scope Global'
Add-Content $distFile 'set-alias frombase64        ConvertFrom-BASE64           -Scope Global'
Add-Content $distFile 'Export-ModuleMember "*-*"'

Write-Host "Complete!"