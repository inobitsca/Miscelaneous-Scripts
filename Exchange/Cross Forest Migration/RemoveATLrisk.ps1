Import-Module ActiveDirectory

$newproxy = "@atlrisk.co.za"
$users = Get-ADGroup -searchbase "OU=ALTRISK USERS,OU=Altrisk,OU=Arcadia,OU=Users Groups,DC=hicnet,dc=loc" -Properties proxyaddresses -filter {proxyaddresses -like "*atlrisk.co.za"} 

Foreach ($user in $users) {
    
$ID = $user.Samaccountname
$newID = $ID -replace "#",""

get-adgroup $ID | Set-ADgroup -remove @{Proxyaddresses="SMTP:"+$NEWID+$newproxy}

get-adgroup $ID | Set-ADgroup -remove @{Proxyaddresses="SMTP:"+$ID+$newproxy}
    } 