$PAM = import-csv C:\Temp\PAMRoles.csv

Foreach ($P in $PAM) {
$PGN = $P.group
$PRN =$P.Role
$Des = $P.Description
$T =$P.TTL

New-adgroup -DisplayName $PGN -name $PGN -GroupCategory Security -GroupScope Global -Description $des -SamAccountName $PGN -Path "OU=MIM,OU=Service Accounts,DC=lfmd,DC=co,DC=za"

$pg = New-PAMGroup –SourceGroupName $PGN –SourceDomain lfmd.co.za  –SourceDC SRPKLDC01 –PrivOnly ## –Credentials $Cred 
$pr = New-PAMRole –DisplayName $PRN –Privileges $pg 

}