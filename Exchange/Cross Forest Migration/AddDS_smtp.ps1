Import-Module ActiveDirectory

$proxydomain = "@altrisk.co.za"
$users = Get-ADUser -searchbase "OU=Users Groups,DC=hicnet,dc=loc" -Properties * -filter {samaccountname -like "ds_*"} 

Foreach ($user in $users) {
$ID = $user.Samaccountname

Get-ADuser $ID | Set-ADUser -Add @{Proxyaddresses="smtp:"+$ID+$proxydomain} 
    } 