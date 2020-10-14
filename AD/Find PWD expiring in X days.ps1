$users =  Get-ADUser -filter *  -Properties PasswordLastSet, extensionattribute7,useraccountcontrol #-SearchBase "OU=OUname,DC=domain,DC=com" #Optional ssearchbase
$today = get-date
$Ucount = $users |measure
$Ucount = $Ucount.count
$num = 1
$neg = 0
$pos = 0
# Password change limit ($PL) in days
$PL = 180
Foreach ($user in $users) {
$PWLS =  $user.PasswordLastSet
$DN = $user.name
$sam = $user.SamAccountName
$PLS = $user.PasswordLastSet
if ($PLS) {$TS1 = NEW-TIMESPAN -Start $user.PasswordLastSet -End $today
$TS2 = $TS1.Days
$TS = $PL - $TS2
#Write-host "Processing account $DN. $num of $ucount" -Fore green

#Set-ADUser $sam -replace @{"extensionattribute7"="$TS"}
}


}
