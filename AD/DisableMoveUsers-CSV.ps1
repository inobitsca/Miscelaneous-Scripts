Import-Module ActiveDirectory 
Import-csv UserList.csv | % {  get-ADuser $_.SamAccountName | Set-ADAccountControl  -Enabled $false -server MMHJHBISODC003.mccarthyltd.local }

# Start-Sleep -s 15

Import-csv UserList.csv | % {  get-ADuser $_.SamAccountName | Move-ADObject -TargetPath "OU=2013-09-20,OU=Disabled to be Deleted,DC=mccarthyltd,DC=local" -server MMHJHBISODC003.mccarthyltd.local}

