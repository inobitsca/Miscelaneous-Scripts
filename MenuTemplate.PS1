<#
    .SYNOPSIS
    Menu with a number of Microsoft Office 365 Hybrid deplyment move options 
   
   	Authors: Cedric Abrahams and Etienne Botha for Netsurit www.netsurit.com
    
	THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE 
	RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.
	CODE MAY BE COPIED, REUSED OR MODIFIED WITHOUT EXPRESS CONSENT OF AUTHOR.
	
	Version 1.0.0, 07 December 2018
	
    .DESCRIPTION
    Menu items displayed below		
    
    
    .EXAMPLE
    .\MenuTemplate.ps1 
#>
#Check for administrative rights
CLS
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script in a PowerShell Session as Administrator!"
    Break
}



#Pre-requsites
Import-module ActiveDirectory
# Import-module OTHER

#Start Menu Loop
CLS
Do { 
while ($choice1 -le "0" -or $choice1 -gt "99" )
{
$Choice1 = 0
$Choice2 = 0
$Choice3 = 0

Write-Host "
---------- MENU ----------
1 = SubMenu1
2 = Option2
3 = Option3
4 = Option4
5 = Option5
6 = SUBMenu6
99 = Quit
--------------------------"  -Fore Green

$choice1 = read-host -prompt "Select number & press enter"
 } 

Switch ($choice1) {


<#

SECTION 1
Enter Description Here

#>
"1" {
# Description
cls
#Start Sub-Menu Loop
#Description 
CLS
Do { 
while ($Choice2 -le "0" -or $Choice2 -gt "99" )
{


Write-Host "
------------- Describe Sub-Menu -------------
1 = SubMenu1.1               
2 = SubMenu1.2 
3 = SubMenu1.3  
99 = Quit Sub Menu                             
-----------------------------------------------"  -Fore Black -back White

$Choice2 = read-host -prompt "Select number & press enter"
 } 

Switch ($Choice2) {

#SECTION 1.1

"1" {
# Description
cls
Write-host "Message to user" -fore Green

Write-host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host "Enter your scripts here"
$Choice2 = 0 
}
#####

#SECTION 1.2

"2" {
# Description
cls
Write-host "Message to user" -fore Green

Write-host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host "Enter your scripts here"
$Choice2 = 0 
}
#####

#SECTION 1.3 

"3" {
# Description
cls
Write-host "Message to user" -fore Green

Write-host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host "Enter your scripts here"
$Choice2 = 0 
}
#####

#SECTION 99 
#Exit Menu

"99" {
$Choice2 = 99
CLS
Write-host = "Sub-Menu closed - Thank you" -fore Cyan
}
}
}while ( $Choice2 -ne "99" )

$Choice1 = 0
}
#####################

#SECTION 2
#Description

"2" {
# Description
cls
Write-host "Message to user" -fore Green

Write-host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host "Enter your scripts here"
$choice1 =0 
}
#####################

#SECTION 3 
#Description

"3" {
# Description
cls
Write-host "Message to user" -fore Green

Write-host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host "Enter your scripts here"
$choice1 = 0
}
######################


#SECTION 4 
#Description

"4" {
# Description
cls
Write-host "Message to user" -fore Green

Write-host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host "Enter your scripts here"
$choice1 = 0
}

######################

#SECTION 5 
#Add E3 licenses to specific users - Confirmation prompt to confirm

"5" {
# Description
cls
Write-host "Message to user" -fore Green

Write-host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host "Enter your scripts here"
$choice1 = 0
}
######################

#Section 6 - Sub Menu

"6" {
CLS
#Start Sub-Menu Loop
#Description
CLS
Do { 
while ($Choice3 -le "0" -or $Choice3 -gt "99" )
{


Write-Host "
---------- Describe Sub-Menu ----------
1 = SubMenu6.1
2 = SubMenu6.2
3 = SubMenu6.3
4 = SubMenu6.4
99 = Quit Sub Menu
--------------------------"  -Fore Yellow

$Choice3 = read-host -prompt "Select number & press enter"
 } 

Switch ($Choice3) {

# SECTION 6.1 
# Description

"1" {
# Description
cls
Write-host "Message to user" -fore Green

Write-host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host "Enter your scripts here"
$choice3 = 0
}
#####

# SECTION 6.2 
# Description

"2" {
cls
Write-host "Message to user" -fore Green

Write-host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host "Enter your scripts here"
$choice3 = 0
}
#####

# SECTION 6.3 
# Description

"3" {
cls
Write-host "Message to user" -fore Green

Write-host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host "Enter your scripts here"
$choice3 = 0
}
#####

# SECTION 6.4 
# Description

"4" {
cls
Write-host "Message to user" -fore Green

Write-host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host "Enter your scripts here"
$choice3 = 0
}
#####

# SECTION 99 
# Exit Menu

"99" {
$Choice3 = 99
CLS
Write-host = "Sub-Menu closed - Thank you" -fore Cyan
}
}
}while ( $Choice3 -ne "99" )

$Choice1 = 0


}
######################


#SECTION 99
#Exit Menu

"99" {
$choice1 = 99
CLS
Write-host = "Menu closed - Thank you" -fore Cyan
}
}
}while ( $choice1 -ne "99" )