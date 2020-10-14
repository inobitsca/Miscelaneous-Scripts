#This script disables and moves user which have not be active for over 90 days
#It creates an OU on the date it runs under the _Disable Users OU
$90Days = (get-date).adddays(-90)
$OUdate = get-date -Format yyyy-MM-dd
$OUname = "Disabled_on_" + $oudate
$OUroot = "OU=_Disabled Objects,DC=Premierfoods,DC=com"
$users = get-aduser -Properties lastlogontimestamp -filter * -SearchBase "OU=Branches,OU=PF Users,DC=Premierfoods,DC=com"
New-ADOrganizationalUnit -Name $OUname -Path $OUroot
$OUPath = "OU=" + $ouname + "," + $OUroot
foreach ($user in $users) {
$sam = $user.SamAccountName
$DN = $user.DistinguishedName
$T = $user.lastlogontimestamp
$TT = [datetime]::FromFileTime($T)
IF ($TT -lt $90Days -and $TT -ne "1601-01-01 02:00:00" ) {
write-host $sam $tt
Disable-ADAccount $sam 
Move-ADObject $DN -TargetPath $OUPath 
}
}