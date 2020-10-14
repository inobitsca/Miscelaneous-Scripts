Write-host "Set Archive Guid"  -fore Green

$users=import-csv "SetArchiveguid.csv"

foreach ($user in $users) {


Write-host "Enabling Remote Mailboxes"  -fore Green
Enable-RemoteMailbox -RemoteRoutingAddress $User.target -Identity $user.upn
write-host $user.upn

Set-RemoteMailbox $user.upn -ArchiveGuid $user.ArchiveGuid

}
