Write-host "Enter full Image path" -fore Green
$Path = Read-host
Write-host "The Base 64 encoded image string will be writen to ImageString.txt in the current directory and diplayed below:" -fore Yellow
sleep -s 3

$String = [convert]::ToBase64String((Get-Content $path -Encoding byte))
Get-date >> .\ImageString.txt
$path >> .\ImageString.txt
$string >> .\ImageString.txt
Write-host "$String" -fore Cyan
