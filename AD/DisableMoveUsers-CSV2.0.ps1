Import-Module ActiveDirectory 

$date=(get-date).AddDays(+90).ToString("yyy-MM-dd")

New-ADOrganizationalUnit -Name $date -Path "OU=Disabled to be Deleted,DC=mccarthyltd,DC=local" -ProtectedFromAccidentalDeletion $false

$SRQNo=Read-host "Enter SRQ Number"
$SRQ=" SRQ "
$Del="Del "
$date=(get-date).AddDays(+90).ToString("yyy-MM-dd")

$Desc=$del+$date+$SRQ+$SRQNo

Import-csv UserList.csv | % {  get-ADuser $_.SamAccountName | Set-ADUser -description $Desc -server MMHJHBISODC003 }


$date=(get-date).AddDays(+90).ToString("yyy-MM-dd")

Import-csv UserList.csv | % {  get-ADuser $_.SamAccountName | Set-ADAccountControl  -Enabled $false -server MMHJHBISODC003.mccarthyltd.local }

Start-Sleep -s 15

$date=(get-date).AddDays(+90).ToString("yyy-MM-dd")

Import-csv UserList.csv | % {  get-ADuser $_.SamAccountName | Move-ADObject -TargetPath "OU=$date,OU=Disabled to be Deleted,DC=mccarthyltd,DC=local" -server MMHJHBISODC003.mccarthyltd.local}

