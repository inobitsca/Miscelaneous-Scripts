Import-Module ActiveDirectory


$users = Get-ADGroupMember -Identity 'GROUPNAME'

Foreach ($user in $users) {
$ID = $user.Samaccountname

Get-ADuser $ID }