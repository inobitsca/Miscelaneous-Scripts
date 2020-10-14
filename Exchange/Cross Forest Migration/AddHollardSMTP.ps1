Import-Module ActiveDirectory

$newproxy = "domainname.com"
$users = Get-ADUser -searchbase "OU=ALTRISK USERS,OU=Altrisk,OU=Arcadia,OU=Users Groups,DC=hicnet,dc=loc" -Properties * -filter {proxyAddresses -notlike 
"*hollard.co.za"} 

Foreach ($user in $users) {
    
$ID = $user.Samaccountname

Set-ADUser -Identity $ID -Add @{Proxyaddresses="smtp:"+$ID+$proxydomain}
    } 