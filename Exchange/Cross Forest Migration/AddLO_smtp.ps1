Import-Module ActiveDirectory

$proxydomain = "@altrisk.co.za"
$users = Get-ADuser -searchbase "OU=Users groups,DC=hicnet,dc=loc" -Properties * -filter {samaccountname -like "LO_*"} 

Foreach ($user in $users) {
$ID = $user.Samaccountname
#$IDNew = $ID -replace '[#]',''
Get-ADuser $ID | Set-ADuser -Add @{Proxyaddresses="smtp:"+$ID+$proxydomain} 

#Get-ADuser $ID | Set-ADuser -Add @{Proxyaddresses="smtp:"+$IDNew+$proxydomain} 
    } 