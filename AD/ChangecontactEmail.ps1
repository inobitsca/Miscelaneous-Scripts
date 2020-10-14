Import-Module ActiveDirectory

$proxydomain1 = "@itecgroup.co.uk"
$proxydomain2 = "@itecgroup.com"
$Contacts = Get-ADObject -Filter "proxyaddresses -like '*portrayal.co.uk*'" -properties *

Foreach ($Contact in $Contacts) {
$ID = $contact.DistinguishedName
$mail = $contact.mail
$NewMail = $contact.Givenname + '.' + $contact.sn + $proxydomain1
Write-host 'Contact to be changed' $contact.displayname 
Write-host 'Old mail address to be removed'  $mail -foregroundcolor red
Write-host 'New mail address to be added' $NewMail -foregroundcolor Green

#Get-ADObject $ID | Set-ADObject -Remove @{Proxyaddresses="SMTP:"+$Mail} 
#Get-ADObject $ID | Set-ADObject -Add @{Proxyaddresses="SMTP:"+$NewMail} 
#Get-ADObject $ID | Set-ADObject -Replace @{mail = $newmail}
#Get-ADObject $ID | Set-ADObject -Replace @{targetaddress = "SMTP:"+$newmail}

    } 