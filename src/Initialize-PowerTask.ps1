# Initialize PowerTask
$global:pt=New-Object System.Collections.Specialized.OrderedDictionary

$softwareDoc =  [xml](Get-Content "$powerTaskPath\softwares.xml" -Encoding UTF8)

Add-Member -MemberType NoteProperty -InputObject $pt -Name version -Value "1.0"
Add-Member -MemberType NoteProperty -InputObject $pt -Name softwareDoc -Value $softwareDoc

set-alias get               Get-Software                 -Scope Global
set-alias install           Install-Software             -Scope Global
set-alias md5               ConvertTo-MD5                -Scope Global
set-alias base64            ConvertTo-BASE64             -Scope Global
set-alias frombase64        ConvertFrom-BASE64           -Scope Global

Export-ModuleMember "*-*"