#Start Sub-Menu Loop
#Capture Credentials and Connect to MSonline and Exchange Online 
CLS
Do { 
while ($Choice2 -le "0" -or $Choice2 -gt "4" )
{


Write-Host "
---------- Connection Sub-Menu ----------
1 = Enter Office 365 credentials
2 = Enter on premis Exchange admin credentials
3 = Connect to Office 365 and Exchange online
4 = Quit Sub Menu
--------------------------"  -Fore Green

$Choice2 = read-host -prompt "Select number & press enter"
 } 

Switch ($Choice2) {

#SECTION 1

"1" {
# Your MSonline admin credential
cls
Write-host "You will now be asked to enter your Office 365 Credentials:" -fore Green
Write-host "e.g. admin@TENANT.onmicrosoft.com"  -fore Green
Write-host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
$cred = Get-Credential
$cred
$Choice2 = 0
}

#SECTION 2

"2" {
CLS
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-host "You will now be asked to enter your onsite Exchange Admin credential:" -fore Cyan
Write-host "e.g. DOMAIN\administrator"  -fore Cyan
Write-host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
$RemCred = Get-Credential
$remcred 
$Choice2 =0 
}

#SECTION 3 

"3" {
CLS
Write-host "Connecting to Office 365, please wait..."
Connect-MsolService -Credential $cred

Write-host "Connecting to Exchange Online, please wait..."

#Connect to remote Exchange Powershell
$S = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Cred -Authentication Basic -AllowRedirection
Import-PSSession $S -allowclobber


$Choice2 = 0
}

#SECTION 4 
#Exit Menu

"4" {
$Choice2 = 4
CLS
Write-host = "Sub-Menu closed - Thank you" -fore Cyan
}
}
}while ( $Choice2 -ne "4" )