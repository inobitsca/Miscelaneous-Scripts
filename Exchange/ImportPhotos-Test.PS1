net use p: /delete /y
net use p: \\nsjnbfs01.netsurit.com\public /y

$usernames = get-mailbox "CedricA"

foreach ($username in $usernames)
{
$photoname = "P:\Pictures\Netsurit Staff Photos\"+$username.name +".jpg"
If (Test-Path $photoname)
{
Write-Host Found Photo for $username.name
Write-Host $photoname
}
Else 
{
Write-host Photo Not Found for $username.name
$photoname = "P:\Pictures\Netsurit Staff Photos\_generic.jpg" 
}
Set-UserPhoto -Identity $username.name -PictureData ([System.IO.File]::ReadAllBytes("$photoname")) -confirm:$false
Set-UserPhoto -Identity $username.name -Save -confirm:$false
} 

