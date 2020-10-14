Import-Module ActiveDirectory


$users = import-csv emailupdate.csv

Foreach ($user in $users) {
  
$Oldmail = $user.old
$newmail =$user.New
$ID = get-aduser -propeties proxyaddresses -filter 'proxyaddresses -like "*$oldmail*"'
#Set-ADUser -Identity $ID -remove @{Proxyaddresses="SMTP:"+$oldmail}
#Set-ADUser -Identity $ID -remove @{Proxyaddresses="smtp:"+$email}
#Set-ADUser -Identity $ID -Add @{Proxyaddresses="SMTP:"+$Newmail}
#Set-ADUser -Identity $ID -Add @{Proxyaddresses="smtp:"+$oldmail}
#Set-ADUser -Identity $ID -emailaddress $newmail 
write-host $ID
} 