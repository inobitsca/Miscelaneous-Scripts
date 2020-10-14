net use p: /delete /y
net use p: \\nsjnbfs01.netsurit.com\public /y

CD "P:\Pictures\Netsurit Staff Photos\"

$transcriptname = "_Photos_Import_" + `
    (Get-Date -format s).Replace(":","-") +".log"
Start-Transcript $transcriptname

$usernames = get-mailbox

foreach ($username in $usernames)
{
$photoname = "P:\Pictures\Netsurit Staff Photos\"+$username.name +".jpg"
If (Test-Path $photoname)
{
Write-Host Found Photo for $username.name *** $photoname `r`n
}
Else 
{
Write-host ERROR - Photo Not Found for $username.name *** Photo should be named """$photoname""" `r`n
$photoname = "P:\Pictures\Netsurit Staff Photos\_generic.jpg" 
}
Set-UserPhoto -Identity $username.name -PictureData ([System.IO.File]::ReadAllBytes("$photoname")) -confirm:$false
Set-UserPhoto -Identity $username.name -Save -confirm:$false -erroraction 'silentlycontinue'
} 
c:
Stop-transcript
