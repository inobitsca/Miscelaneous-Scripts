Import-Module ActiveDirectory

$newproxy = "domainname.com"
$users = Get-ADUser -searchbase "OU=ALTRISK USERS,OU=Altrisk,OU=Arcadia,OU=Users Groups,DC=hicnet,dc=loc" -Properties proxyaddresses -filter * 

Foreach ($user in $users) {
    
$ID = $user.Samaccountname

get-aduser $ID | Set-ADUser -remove @{Proxyaddresses="SMTP:"+$ID}
    } 