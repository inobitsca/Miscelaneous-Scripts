write-host "Upload photo for Office 365 users:"
Import-module msonline
Import-module ActiveDirectory
# Enter your MSonline admin credential

Write-host "You will now be asked to enter your Office 365 admin credentials:" -fore Green
Write-host "e.g. admin@TENANT.onmicrosoft.com"  -fore Green
Write-host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
$cred = Get-Credential


Write-host "Connecting to Office 365, please wait..."
Connect-MsolService -Credential $cred

Write-host "Connecting to Exchange Online, please wait..."

Connect to remote Exchange Powershell

$S = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Cred -Authentication Basic -AllowRedirection
Import-PSSession $S -allowclobber

Do { 
while ($choice1 -le "0" -or $choice1 -gt "99" )
{
$Choice1 = 0
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host "---------- MENU ----------" -Fore Green
Write-Host "1  = Upload a photo" -Fore Green
Write-Host "99 = Quit" -Fore Green
Write-Host "-----------------------------"  -Fore Green

$choice1 = read-host -prompt "Select number and press enter"
} 

Switch ($choice1) {

#SECTION 1

"1" {
CLS

$upn = read-host "Enter the username of the user that you are uploading a photo for e.g. User@netsurit.com:"
$username = $UPN -Replace "@netsurit.com", ""
$username = $UPN -Replace "@inobits.com", ""
$useraccount = get-aduser -identity $username  -server nsjnbdc02.netsurit.com -Credential $cred
$Display = $useraccount.name
$photoname = "\\nsjnbfs01.netsurit.com\public\Pictures\Netsurit Staff Photos\"+ $Display +".jpg"
If (Test-Path $photoname)
{
Write-Host Found Photo for $username.name
Write-Host $photoname

Set-UserPhoto -Identity $username -PictureData ([System.IO.File]::ReadAllBytes("$photoname")) -confirm:$false
Set-UserPhoto -Identity $username -Save -confirm:$false
$Choice1 = 0
}
Else 
{
Write-host Photo Not Found -Fore Red
Write-host  """$photoname""" -fore Red
Write-host Using generic photo -Fore Yellow
$photoname = "\\nsjnbfs01.netsurit.com\\Pictures\Netsurit Staff Photos\_generic.jpg" 
Write-host  """$photoname""" -fore yellow
Set-UserPhoto -Identity $username -PictureData ([System.IO.File]::ReadAllBytes("$photoname")) -confirm:$false
Set-UserPhoto -Identity $username -Save -confirm:$false
$Choice1 = 0
}}}

}while ( $choice1 -ne "99" )
