#Start Sub-Menu Loop
#Capture Credentials and Connect to MSonline and Exchange Online 
CLS
Do { 
while ($Choice3 -le "0" -or $Choice3 -gt "99" )
{


Write-Host "
---------- Move Sub-Menu ----------
1 = Get move statistics for a specific user
2 = Get move statistics for all current move requests
3 = Remove completed move requests 
4 = Suspend all move requests 
5 = Suspend individual move request 
6 = Resume all move requests
7 = Resume individual move request
8 = Remove all move requests
9 = Remove individual move request
99 = Quit Sub Menu
--------------------------"  -Fore Yellow

$Choice3 = read-host -prompt "Select number & press enter"
 } 

Switch ($Choice3) {

#SECTION 1 
# Get move statistics for a specific user

"1" {
CLS
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
write-host "Enter the AD User Principal Name" -fore Green
write-host "e.g. user@domain.com" -fore Green
$U = Read-Host 

Get-MoveRequest -identity $U |Get-MoveRequestStatistics | ft displayname,TotalMailboxSize,BytesTransferred,TotalMailboxItemCount,ItemsTransferred,PercentComplete,StatusDetail

$choice3 = 0
}

#SECTION 2 
# Get move statistics for all current move requests

"2" {
CLS
write-host "Getting Move Statistics" -fore Green
Get-MoveRequest |Get-MoveRequestStatistics | ft displayname,TotalMailboxSize,BytesTransferred,TotalMailboxItemCount,ItemsTransferred,PercentComplete,StatusDetail

$choice3 = 0
}

#SECTION 3 
#Remove completed move requests - Confirmation prompt to confirm

"3" {
CLS
Get-MoveRequest |where-object {$_.status -eq "Completed"} | remove-moverequest

$choice3 = 0
}


#SECTION 4 
#Suspend all move requests - Confirmation prompt to confirm

"4" {
CLS
Get-MoveRequest |suspend-moverequest

$choice3 = 0
}

#SECTION 5 
#Suspend individual move request - Confirmation prompt to confirm

"5" {
CLS
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
write-host "Enter the AD User Principal Name" -fore Green
write-host "e.g. user@domain.com" -fore Green
$U = Read-Host 
Get-MoveRequest $U | suspend-moverequest

$choice3 = 0
}

#SECTION 6 
#Resume all move requests - Confirmation prompt to confirm

"6" {
CLS
Get-MoveRequest |resume-moverequest

$choice3 = 0
}

#SECTION 7 
#Resume individual move request - Confirmation prompt to confirm

"7" {
CLS
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
write-host "Enter the AD User Principal Name" -fore Green
write-host "e.g. user@domain.com" -fore Green
$U = Read-Host 
Get-MoveRequest $U | Resume-moverequest

$choice3 = 0
}

#SECTION 8 
#Remove all move requests - Confirmation prompt to confirm

"8" {
CLS
Get-MoveRequest |remove-moverequest

$choice3 = 0
}

#SECTION 9 
#Remove individual move request - Confirmation prompt to confirm

"9" {
CLS
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
write-host "Enter the AD User Principal Name" -fore Green
write-host "e.g. user@domain.com" -fore Green
$U = Read-Host 
Get-MoveRequest $U | Remove-moverequest

$choice3 = 0
}


#SECTION 99 
#Exit Menu

"99" {
$Choice3 = 99
CLS
Write-host = "Sub-Menu closed - Thank you" -fore Cyan
}
}
}while ( $Choice3 -ne "99" )