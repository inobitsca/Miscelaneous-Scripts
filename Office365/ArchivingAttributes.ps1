import-module activedirectory

$users=import-csv c:\temp\move.txt

foreach ($user in $users) {

$U = $user.upn

$U1 = get-aduser -properties * -filter 'displayname -eq $U'

$A = $U1.SAMACCOUNTNAME

$M = $U + "-Online Archive"

write-host $U" ; "$A

set-ADUser -Identity $A-Replace @{msExchRecipientDisplayType="3"}
set-ADUser -Identity $A -Replace @{msExchArchiveName=$M}

}
