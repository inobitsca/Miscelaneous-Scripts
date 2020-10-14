$contacts = Get-ADObject -Properties * -Filter 'displayName -like "*_SMScl*"'

Foreach ($cont in $contacts) {

$Newmail = $cont.mail -replace "ez-pz.mobi" , "email2sms.channelmobile.co.za"
$Newmail
$newtarget = "SMTP:" + $newmail
$newtarget
set-adobject $cont -Replace @{mail= ($newmail)}
set-adobject $cont -Replace @{targetAddress= ($newtarget)}

}