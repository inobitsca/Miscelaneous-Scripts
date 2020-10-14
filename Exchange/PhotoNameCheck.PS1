CD "P:\Pictures\Netsurit Staff Photos\"

$transcriptname = "_PhotosNotFound" + `
    (Get-Date -format s).Replace(":","-") +".log"
Start-Transcript $transcriptname

$usernames = get-mailbox

foreach ($username in $usernames)
{
$photoname = ""+$username.name +".jpg"
If (Test-Path $photoname)
{
#Write-Host Found Photo for $username.name *** """$photoname"""
}
Else 
{
Write-host Photo Not Found for $username.name *** Photo should be named """$photoname""" `r`n
# $photoname = "P:\Pictures\Netsurit Staff Photos\netsurit.jpg"
}
#Set-UserPhoto -Identity $username.name -PictureData ([System.IO.File]::ReadAllBytes("$photoname")) -confirm:$false -Whatif
#Set-UserPhoto -Identity $username.name -Save -confirm:$false -Whatif
} 

Stop-transcript
