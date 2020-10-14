# This scrip must be used on machine that has the Active Directory RSAT tools installed.
#The AD user account must have AD rights to adminiter group memnership.

write-host "Do you want to install the AzureAD PowerShell module? Y/N" -fore Green
$IAAD = Read-host

If ($IAAD -eq "y") {Install-Module -Name AzureAD}

Write-host "Do you want to install the MS Online PowerShell module? Y/N" -fore Green
$IMSO = Read-host 
If ($IMSO -eq "y") {Install-Module -Name MSonline}
Sleep -s 1
Write-host "You will now connect to MS Online and Azure AD."
Write-host "You will be asked for your credentials for each"

Sleep -s 2

Connect-MSOLService
Sleep -s 2
Connect-AzureAD
Sleep -s 2
Import-module ActiveDirectory

#CSV must have a column call UPN  containing the User Principal Name 
$users = import-csv c:\temp\userlist.csv #Edit Path as needs be.

#####################
Write-host "Removing user from on premise AD groups" -Fore Yellow
sleep -s 2
Foreaeach ($u in $users) {

$ADGroups = (Get-ADuser -Identity $U.UPN -Properties memberof).memberof 
Foreach ($ADgroup in $ADGroups){
Remove-ADGroupMember -Identity $ADgroup.name -Members $U.Samaccountname -confirm $False
}

}

#########################
Write-host "Removing user from Azure AD groups" -Fore Yellow
sleep -s 2
Foreach ($u in $users) {
$UD = Get-MsolUser -UserPrincipalName $u.UPN
$UID = $UD.ObjectId

$AZgroups = Get-AzureADUserMembership -ObjectId $UID
Foreach ($AZgroup in $AZGroups) {
Remove-AzureADGroupMember -ObjectId $AZgroup.id -MemberId $UID
}

}