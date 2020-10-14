<#
    .SYNOPSIS
    Menu with a number of Microsoft Office 365 Hybrid deplyment move options 
   
   	Authors: Cedric Abrahams  for Netsurit
    
	THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE 
	RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.
	CODE MAY NOT BE COPIED, REUSED OR MODIFIED WITHOUT EXPRESS CONSENT OF AUTHOR.
	
	Version 1.0.0, 15 April 2015
	
    .DESCRIPTION
    Menu items displayed below		
    The following are pre-requisites:
	-For option 3, a text file c:\temp\move.txt with "UPN" on the first line
	-The Microsoft Signin assistant must be installed
	-The Microsoft online PowerShell Module must be installed
	-The Active Directory PowerShell Module must be installed
	
    
    .EXAMPLE
    .\MoveMenu.ps1 
#>

If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
Write-host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
    Break
}


#Pre-requsites
Import-module MSonline
Import-module ActiveDirectory

#Start Menue Loop
CLS
Do { 
while ($choice1 -le "0" -or $choice1 -gt "7" )
{


Write-Host "
---------- MENU ----------
1 = Connect to Office 365 - Do this first
2 = Add Email Addresses to a list of users (CSV)
3 = Assign a secondary email address to a user
4 = Force a Directory Synchronization 
5 = Force a FULL Directory Synchronization 
6 = Reserved for a future menu item
7 = Quit
--------------------------"  -Fore Green

$choice1 = read-host -prompt "Select number & press enter"
 } 

Switch ($choice1) {

#SECTION 1
#Connect to MSonline and Exchange Online 
#Capture Exchange on premise credentials required for Move requests

"1" {
# Your MSonline admin credential
cls
Write-host "You will now be asked to enter your Office 365 Credentials:" -fore Green
Write-host "e.g. admin@TENANT.onmicrosoft.com"  -fore Green
Write-host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
$cred = Get-Credential
$cred
Write-host "Connecting to Microsoft Online."
Connect-MsolService -Credential $cred

#Connect to remote Exchange Powershell
Write-host "Connecting to Exchange Online."
$S = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Cred -Authentication Basic -AllowRedirection
Import-PSSession $S -allowclobber

$choice1 = 0

}

#SECTION 2
#Add primary and secondary email addresses to users in a CSV file. Assign E1 Licenses.

"2" {
CLS

Write-host Import email addresses and assign E1 liceses for users.

$file = read-host "Please enter the CSV file to import (full path)"

$users = import-csv $file
foreach ($u in $users) {
$UPN = $U.EmailAddress
$ADUser = get-aduser -filter 'Userprincipalname -eq $UPN'
$ID = $Aduser.samaccountname
$E = $U.Username
Write-host $ID

Set-ADUser -Identity $ID -Add @{Proxyaddresses="SMTP:"+$E}
Set-ADUser -Identity $ID -Add @{Proxyaddresses="smtp:"+$ID+"@spcawh.onmicrosoft.com"}
Set-ADUser -Identity $ID -emailaddress $E

Set-msoluser -userprincipalname $UPN -usagelocation ZA
Set-msoluserlicense -userprincipalname $UPN -addlicense "syndication-account:STANDARDPACK"
}

$choice1 =0 
}

#SECTION 3 
#Add secondary email address to a user
"3" {
CLS
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-host "Add secondary email address to a user

"
$U = read-host Enter the AD username which will be getting a secondary email address
$E = Read-Host Enter the secondary email address as USER@example.com
Set-ADUser -Identity $U -Add @{Proxyaddresses="smtp:"+$E}
Get-aduser $u -properties proxyaddresses |fl Samaccountname, proxyaddresses


$choice1 = 0
}

#SECTION 4 
# Force Directory Sync

"4" {
CLS

Start-OnlineCoexistenceSync

Write-host Synchronization started
Write-host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

$choice1 = 0
}

#SECTION 5 
# Force FULL Directory Sync

"5" {
CLS
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Start-OnlineCoexistenceSync -fullsync

Write-host "Full Synchronization started."
Write-host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")


$choice1 = 0
}

#SECTION 6 
#Reserved for future menu item

"6" {
CLS
Write-Host "This is reserved for a future menu item."
Write-host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

$choice1 = 0
}


#SECTION 7
#Exit Menu

"7" {
CLS
Write-host = "Menu closed - Thank you" -fore Cyan
}

} 

}while ( $choice1 -ne "7" )
