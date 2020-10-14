#Check for administrative rights
CLS
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script in a PowerShell Session as Administrator!"
    Break
}



Import-module Dirsync
Set-FullPasswordSync
net stop "Windows Azure Active Directory Sync Service"
net stop "Forefront Identity Manager Synchronization Service"
net start "Forefront Identity Manager Synchronization Service"
net start "Windows Azure Active Directory Sync Service"
Start-OnlineCoexistenceSync -FullSync