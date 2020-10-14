Import-Module ActiveDirectory


$SAM = Read-host 

Write-host "
Email Address Changes
1. Add new primary email address
2. Add new secondary address
3. Add a new alias
3. Remove an alias
"
$number

$user = $Get-aduser $SAM -propeties proxyaddresses,mail

$oldPri = $user.mail  

$newPri = Read-Host 

$Alias = Read-host
  
#Add new Primary
Set-ADUser -Identity $ID -remove @{Proxyaddresses="SMTP:"+$oldPri}
Set-ADUser -Identity $ID -Add @{Proxyaddresses="smtp:"+$oldPri}
Set-ADUser -Identity $ID -Add @{Proxyaddresses="SMTP:"+$newPri}
Set-ADUser -Identity $ID -emailaddress $newPri


#Add new secondary  
Set-ADUser -Identity $ID -Add @{Proxyaddresses="smtp:"+$Alias}

# Remove Alias
Set-ADUser -Identity $ID -remove @{Proxyaddresses="smtp:"+$Alias}


#Swap Primary and Secondary
Set-ADUser -Identity $ID -remove @{Proxyaddresses="SMTP:"+$oldPri}
Set-ADUser -Identity $ID -Add @{Proxyaddresses="smtp:"+$oldPri}
Set-ADUser -Identity $ID -remove @{Proxyaddresses="smtp:"+$newPri}
Set-ADUser -Identity $ID -Add @{Proxyaddresses="SMTP:"+$newPri}
Set-ADUser -Identity $ID -emailaddress $newPri

   
