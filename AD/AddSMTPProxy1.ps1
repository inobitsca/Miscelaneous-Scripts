Import-Module ActiveDirectory


$users = import-csv bulkemailupdate1.csv

Foreach ($user in $users) {
    
$ID = $user.UPN
$email = $user.email

Set-ADUser -Identity $ID -Add @{Proxyaddresses="SMTP:"+$email}

    } 