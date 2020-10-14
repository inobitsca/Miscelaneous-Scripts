Import-module ActiveDirectory
# Create a new AD Group to use for a PAM Role - Must Be run by an account with appropriate rights
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
