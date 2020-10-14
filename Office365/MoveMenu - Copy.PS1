<#
    .SYNOPSIS
    Menu with a number of Microsoft Office 365 Hybrid deplyment move options 
   
   	Authors: Cedric Abrahams for Netsurit
    
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

#Pre-requsites
Import-module MSonline
Import-module ActiveDirectory

#Start Menu Loop
CLS
Do { 
while ($choice1 -le "0" -or $choice1 -gt "9" )
{


Write-Host "
---------- MENU ----------
1 = Connect to Office 365 - Do this first
2 = Move a specific user to O365
3 = Move a list of users to O365
4 = Get move statistics for a specific user
5 = Get move statistics for all moves
6 = Remove all completed move requests 
7 = Assign E1 Licenses to a list of users
8 = Assign E3 Licenses to a list of users
9 = Quit
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
$Choice1 = 0
}

#SECTION 2
#Move individual user - Edit connection string for the correct domains

"2" {
CLS
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host "Enter the AD User Principal Name"  -fore Green
write-host "e.g. user@domain.com" -fore Green
$U = Read-Host

set-msoluser –userprincipalname $U -UsageLocation za
New-MoveRequest -identity $U -Remote -RemoteHostName www.mail.stortech.co.za -RemoteCredential $RemCred -TargetDeliveryDomain “vb000146.onmicrosoft.com” -AcceptLargeDataLoss -BadItemLimit 1000
Write-Host "Please remember to assign alicense to" $U  -fore Green $U
	
$choice1 =0 
}

#SECTION 3 
#Move users based on CSV. NB Edit License details
#Ensure there is a text file c:\temp\move.txt. 
#The file must have the the first line with UPN on it
#The file will have a list of either email addresses or UPNs, each on a new line

"3" {
CLS
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
write-host "Edit the list of users in the file that will now open" -fore Green
write-host "Leave the 1st line as UPN" -fore Green
write-host "Users must be in UPN format e.g. user@stortech.co.za" -fore Red
write-host "when you have finished editing, please save and close it." -fore Green
Write-host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
c:\temp\move.txt

CLS
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-host "Press any key to start the move."  -fore Green
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

CLS
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-host "Move starting. This may take some time..."  -fore Green

$users=import-csv c:\temp\move.txt

foreach ($user in $users) {

$U = $user.upn 

write-host $U

# Set-Mailbox $U -Type “Shared” 

set-msoluser –userprincipalname $U -UsageLocation za


#----*****EDIT CONNECTION STRING FOR THE CORRECT DOMAINS*****----
New-MoveRequest -identity $U -Remote -RemoteHostName www.mail.stortech.co.za -RemoteCredential $RemCred -TargetDeliveryDomain “vb000146.onmicrosoft.com” -AcceptLargeDataLoss -BadItemLimit 1000
}

Get-moverequest |ft

$choice1 = 0
}

#SECTION 4 
# Get move statistics for a specific user

"4" {
CLS
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
write-host "Enter the AD User Principal Name" -fore Green
write-host "e.g. user@domain.com" -fore Green
$U = Read-Host 

Get-MoveRequest -identity $U |Get-MoveRequestStatistics | ft displayname,TotalMailboxSize,BytesTransferred,TotalMailboxItemCount,ItemsTransferred,PercentComplete,StatusDetail

$choice1 = 0
}

#SECTION 5 
# Get move statistics for all current move requests

"5" {
CLS
write-host "Getting Move Statistics" -fore Green
Get-MoveRequest |Get-MoveRequestStatistics | ft displayname,TotalMailboxSize,BytesTransferred,TotalMailboxItemCount,ItemsTransferred,PercentComplete,StatusDetail

$choice1 = 0
}

#SECTION 6 
#Remove completed move requests - Confirmation prompt to confirm

"6" {
CLS
Get-MoveRequest |where-object {$_.status -eq "Completed"} | remove-moverequest

$choice1 = 0
}


#SECTION 7 
#Add E1 licenses to specific users - Confirmation prompt to confirm

"7" {
CLS
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
write-host "Edit the list of users in the file that will now open" -fore Green
write-host "Leave the 1st line as UPN" -fore Green
write-host "Users must be in UPN format e.g. user@stortech.co.za" -fore Red
write-host "when you have finished editing, please save and close it." -fore Green
Write-host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
c:\temp\E1.txt

CLS
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-host "Press any key to start license assignment."  -fore Green
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

CLS
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-host "Adding licenses. This may take some time..."  -fore Green

$users=import-csv c:\temp\E1.txt

foreach ($user in $users) {

$U = $user.upn 
set-msoluser –userprincipalname $U -UsageLocation za
set-msoluserlicense –userprincipalname $U –addlicenses "syndication-account:STANDARDPACK"
}

$choice1 = 0
}

####

#SECTION 8 
#Add E3 licenses to specific users - Confirmation prompt to confirm

"8" {
CLS
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
write-host "Edit the list of users in the file that will now open" -fore Green
write-host "Leave the 1st line as UPN" -fore Green
write-host "Users must be in UPN format e.g. user@stortech.co.za" -fore Red
write-host "when you have finished editing, please save and close it." -fore Green
Write-host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
c:\temp\E3.txt

CLS
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-host "Press any key to start license assignment."  -fore Green
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

CLS
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-host "Adding licenses. This may take some time..."  -fore Green

$users=import-csv c:\temp\E3.txt

foreach ($user in $users) {

$U = $user.upn 
set-msoluser –userprincipalname $U -UsageLocation za
set-msoluserlicense –userprincipalname $U –addlicenses "syndication-account:Enterprisepack"
}
$choice1 = 0
}


#SECTION 9
#Exit Menu

"9" {
$choice1 = 9
CLS
Write-host = "Menu closed - Thank you" -fore Cyan
}
}
}while ( $choice1 -ne "9" )