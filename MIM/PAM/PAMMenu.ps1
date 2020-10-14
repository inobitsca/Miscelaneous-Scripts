<#
    .SYNOPSIS
    Menu with a number of PAM options 
   
   	Authors: Cedric Abrahams for Netsurit www.netsurit.com
    
	THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE 
	RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.
	CODE MAY BE COPIED, REUSED OR MODIFIED WITHOUT EXPRESS CONSENT OF AUTHOR.
	
	Version 1.0.0, 20 December 2018
	
    .DESCRIPTION
    Menu items displayed below		
    
    
    .EXAMPLE
    .\PAMMenu.ps1 
#>
#Check for administrative rights
<# CLS
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script in a PowerShell Session as Administrator!"
    Break
}

 #>

#Pre-requsites
Import-module ActiveDirectory
Import-Module MIMPAM
# Import-module OTHER

#Start Menu Loop
CLS
Do { 
while ($choice1 -le "0" -or $choice1 -gt "99" )
{
$Choice1 = 0
$Choice2 = 0
$Choice3 = 0
$Choice4 = 0
$Choice5 = 0


Write-Host "
---------- MAIN MENU ----------
1 = Create PAM Objects Submenu
2 = PAM Object Management
3 = Request Management - Future
88 = Clear Screen
99 = Quit
--------------------------"  -Fore Green

$choice1 = read-host -prompt "Select number & press enter"
 } 

Switch ($choice1) {


<#

SECTION 1
Create PAM objects Submenu

#>
"1" {
# Create PAM objects Submenu

#Start Sub-Menu Loop

Do { 
while ($Choice2 -le "0" -or $Choice2 -gt "99" )
{


Write-Host "
------------- PAM object Creation Sub-Menu -------------
1 = Create new PAM user               
2 = Create PAM Group and Role
99 = Quit Sub Menu                             
-----------------------------------------------"  -Fore cyan

$Choice2 = read-host -prompt "Select number & press enter"
 } 

Switch ($Choice2) {

#SECTION 1.1

"1" {
# Create a new PAM user from an Existing User Account
Write-host ""
Write-host "Create a new PAM user from an Existing User Account" -fore Green
Write-host ""
If (!$cred) {
Write-host "Enter your PAM Admin Credentials" -Fore Green
$cred = Get-Credential
}

    $Sa = Read-Host "Enter the SAMAccountName of the User that will have a privliged account"
	$PA = Read-Host "Enter the account name for the new privliged account"
	$pw = Read-Host "Enter the new privliged account password?" -AsSecureString
	Write-host "Running command: New-PAMUser –SourceDomain premierfoods.com –SourceAccountName $Sa" -fore Yellow
	New-PAMUser –SourceDomain premierfoods.com –SourceAccountName $Sa -PrivAccountName $PA
  
  #### Changes the PAM Account password and status
    $EM = $PA + "@premierFMCG.com"
	Set-ADAccountPassword –identity $pa –NewPassword $pw
	Set-ADUser –identity $pa –Enabled 1
	Set-ADUser –identity $pa -ChangePasswordAtLogon $False 
	Set-ADUser -identity $pa 
	Set-ADUser -identity $pa -givenname $pa -Surname $pa -EmailAddress $em -description "Reconciling Clerk" -displayname $pa -OfficePhone $null
	get-aduser $PA |Move-adobject  -TargetPath "OU=Waterfall,OU=Branches,OU=PF Users,DC=Premierfoods,DC=com"

$Choice2 = 0 
}
#####

#SECTION 1.2

"2" {
# Create a new Role For an Existing Group
Write-host ""
Write-host "Create a new PAM Role" -fore Green
Write-host ""
$LOS = $env:logonserver
if (!$LOS) {$LOS = "GLHCVAD04"}
$LO = $LOS -replace "\\" ,""
Write-host "Enter the GroupName that will used for the PAM Role" -fore Green
$GN = Read-Host 
Write-host "Enter the PAM Role Name" -fore Green
$RN = Read-Host 
Write-host "Enter the PAM Role Description" -fore Green
$RD = Read-Host 
If (!$cred) {
Write-host "Enter your PAM Admin Credentials" -Fore Green
$cred = Get-Credential
}

$pg = New-PAMGroup –SourceGroupName $GN –SourceDomain premierfoods.com  –SourceDC $LO -credential $cred –PrivOnly 
$pr = New-PAMRole –DisplayName $RN –Privileges $pg -Description $RD


$Choice2 = 0 
}
#####

#SECTION 1.3 

"3" {
# Create a new AD Group to use for a PAM Role - NOT FUNCTIONAL
Write-host ""
Write-host "Create a new AD Group to use for a PAM Role" -fore Green
Write-host ""


    $GN = Read-Host "Enter the SAMAccountName of the new Group"
	$NGD = Read-Host "Enter the description of the new group"

	Write-host "Creating the new group $GN" -fore Yellow
	New-ADGroup -name $GN -DisplayName $GN -Description $NGD -Path "OU=MIM,OU=Service Accounts,OU=PF Users,DC=Premierfoods,DC=com" -GroupCategory Security -GroupScope Global
  
  #### Changes the PAM Account password and status
Write-Host " Setting permissions on the group." -fore green
sleep -s 2

$GRP = Get-adgroup $GN
$GRP1 = "AD:\" + $GRP.DistinguishedName	

$acl = get-acl $GRP1
$acl.SetAccessRuleProtection($true,$true) 
set-acl -aclobject $ACL $GRP1
#Display the new state 
(Get-Acl $GRP1).AreAccessRulesProtected 
dsacls $grp  /takeownership

$acl=Get-Acl -Path "AD:\CN=MIMTemplateGroup,OU=MIM,OU=Service Accounts,OU=PF Users,DC=Premierfoods,DC=com" 
$acls = Set-ACL -Path $GRP1 $acl
get-acl $GRP1 |Fl


$Choice2 = 0 
}


#SECTION 99 
#Exit Menu

"99" {
$Choice2 = 99
Write-host ""
Write-host = "Sub-Menu closed - Thank you" -fore Cyan
sleep -s 1
}
}
}while ( $Choice2 -ne "99" )

$Choice1 = 0
}
#####################

#SECTION 2
#PAM User Management Sub-Menu

"2" {

#Start Sub-Menu Loop


Do { 
while ($Choice3 -le "0" -or $Choice3 -gt "99" )
{


Write-Host "
---------- PAM User Management Sub-Menu ----------
1 = Add PAM Users to a PAM Role
2 = Remove a PAM User From a PAM Role
3 = Remove a PAM user from the system
4 = List PAM users for a PAM Role
5 = List PAM users
6 = List PAM Roles
99 = Quit Sub Menu
--------------------------"  -Fore Yellow

$Choice3 = read-host -prompt "Select number & press enter"
 } 

Switch ($Choice3) {


#SECTION 2.1 

"1" {
# Add a PAM User to a PAMRole
Write-host ""
Write-host "Add PAM Users to a PAM Role" -fore Green

Write-host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-host "Availible PAM Roles" -fore Green
Get-Pamrole |ft Displayname,description
Write-host "Enter the PAMRole DisplayName" -fore Green
$RN =read-host 
$PR = Get-PAMRole -DisplayName $RN
Write-host "Availible Users" -fore Green
Get-PamUser|ft Sourceaccountname,SourceDisplayname
Write-host "Enter the PAMUser SourceAccountName" -fore Green
$RCN =read-host 

$RC = get-pamuser -SourceAccountName $RCN

$r = Get-PAMRole -DisplayName $RN 
$nc = $r.Candidates + (Get-PAMUser -PrivDisplayName $RC.PrivDisplayName) 
$r = Set-PAMRole -Role $r -Candidates $nc

#Check the outcome
$RC1 = Get-PAMRole -DisplayName $RN 
Write-host "Candidates in PAM Role $RN" -fore Green
$RC1.Candidates |ft Sourceaccountname,Privaccountname
$Choice3 = 0 
}
#####

#####

#SECTION 2.2 

"2" {
# Remove a PAM User From a PAM Role
Write-host ""
Write-host "Remove a PAM User From a PAM Role" -fore Green

Write-host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-host "Availible PAM Roles" -fore Green
Get-Pamrole |ft Displayname,description
Write-host "Enter the PAMRole DisplayName" -fore Green
$RN =read-host 
$PR = Get-PAMRole -DisplayName $RN
Write-host "Availible Users to remove" -fore Green
$PR.candidates |ft Sourceaccountname,Privaccountname,SourceDisplayName
Write-host "Enter the PAMUser SourceAccountName" -fore Green
$RCN =read-host 

$RC = get-pamuser -SourceAccountName $RCN

$r = Get-PAMRole -DisplayName $RN 

$RC2 = $R.candidates|where {$_.sourceaccountname -ne $RCN}
Set-PAMRole -Role $r -Candidates $RC2

#Check the outcome
$RC1 = Get-PAMRole -DisplayName $RN 
Write-host "Candidates now in the PAM Role $RN" -fore Green
$RC1.candidates |ft SourceDisplayName,Sourceaccountname,Privaccountname
$Choice3 = 0 
}
#####

# Section 2.3
"3" {
# Delete a PAM user from an Existing User Account
Write-host ""
Write-host "Delete a PAM user from an Existing User Account" -fore Green

Write-host "Availible Users" -fore Green
Get-PamUser|ft Sourceaccountname,SourceDisplayname
    $SA = Read-Host "Enter the SAMAccountName of the User that will have theit PAM account removed"
	$RC = get-pamuser -SourceAccountName $SA
    remove-PAMUser $RC
    

$Choice3 = 0 
}
#####
# Section 2.4
"4" {
# List PAM users for a PAM Role
Write-host ""
Write-host "List PAM users for a PAM Role" -fore Green


Write-host "Availible PAM Roles" -fore Green
Get-Pamrole |ft Displayname,description
Write-host "Enter the PAMRole DisplayName" -fore Green
$RN =read-host 
$PR = Get-PAMRole -DisplayName $RN
Write-host "Users to in PAM Role $RN" -fore Green
$PR.candidates |ft Sourceaccountname,Privaccountname,SourceDisplayName
    

$Choice3 = 0 
}
#####

#####
# Section 2.5
"5" {
# List PAM users
Write-host ""
Write-host "Availible PAM users" -fore Green

get-pamuser |ft Sourceaccountname,Privaccountname,SourceDisplayName
    

$Choice3 = 0 
}
#####

# Section 2.6
"6" {
# List PAM Roles
Write-host ""
Write-host "Availible PAM Roles" -fore Green

get-pamrole |ft DisplayName,Description
    

$Choice3 = 0 
}
#####

# SECTION 99 
# Exit Menu

"99" {
$Choice3 = 99

Write-host = "Sub-Menu closed - Thank you" -fore Cyan
sleep -s 1
}
}
}while ( $Choice3 -ne "99" )

$Choice1 = 0


} 
######################


#####################

#SECTION 3 - Future Section
#Request Management - Future

"3" {


Write-host "This section is for Request Management to be implimented in the Future" -fore Yellow


#Start Sub-Menu Loop
#Description 

Do { 
while ($Choice4 -le "0" -or $Choice4 -gt "99" )
{


Write-Host "
------------- PAM Activation Sub-Menu -------------
1 = Request Role Activation               
2 = Approve Role Activation - Future 
99 = Quit Sub Menu                             
-----------------------------------------------"  -Fore Black -back White

$Choice4 = read-host -prompt "Select number & press enter"
 } 

Switch ($Choice4) {


#SECTION 4.1 

"1" {
# Requst PAMRole Activation

Write-host "Requst PAMRole Activation" -fore Green

Write-host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-host "Availible PAM Roles for activation" -fore Green
Get-Pamrole |ft Displayname,description -WarningAction SilentlyContinue
Write-host "Enter the PAMRole DisplayName you wish to activate" -fore Green
$RA = read-host 
Write-host "Enter the Justification for this activation" -fore Green
$RJ = read-host 
Write-host "Enter the tamespan you wish to activate this role for. Minimum 00:05, Maximum 01:00, Default 01:00" -fore Green
$RT = read-host 
if (!$RT) {$RT = "01:00"}
#Write-host "Enter the future time you wish to activate the PAMRole" -fore Green
#$SF = read-host 
#$now = get-date
#if ($SF) {if (!$SF -gt $now) {$SF = get-date}} else {$SF = get-date}
$PR = Get-PAMRole -DisplayName $RA -WarningAction SilentlyContinue

New-PAMRequest -Role $PR -Justification $RJ -RequestedTTL $RT # -RequestedTime $SF


$Choice4 = 0 
}
#####

#####

#SECTION 4.2 

"2" {
# Future Command

Write-host "Future Command" -fore Green

$Choice4 = 0 
}
#####

# Section 4.3
"3" {
# Future Command

Write-host "Future Command" -fore Green

$Choice4 = 0
}
#####


# SECTION 99 
# Exit Menu

"99" {
$Choice4 = 99

Write-host = "Sub-Menu closed - Thank you" -fore Cyan
}
}
}while ( $Choice4 -ne "99" )

$Choice1 = 0


} 
######################


#SECTION 4  - Future Section
#Description

"4" {
# Description

Write-host "Future Section" -fore Green

Write-host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host "Enter your scripts here"
$choice1 = 0
}

######################

#SECTION 5 
#Description  - Future Section

"5" {
# Description

Write-host "Future Section" -fore Green

Write-host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host "Enter your scripts here"
$choice1 = 0
}
######################

#SECTION 88 
#Clear Screen

"88" {

CLS
$choice1 = 0
} 

######################
 
#SECTION 99
#Exit Menu

"99" {
$choice1 = 99
Write-host ""
Write-host = "Menu closed - Thank you" -fore Cyan
}
}
}while ( $choice1 -ne "99" )