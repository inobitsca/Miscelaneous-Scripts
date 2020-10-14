import-module activedirectory
$users = get-aduser -filter * 
$DCs = Get-ADDomainController -Filter *
$FileDate = get-date -Format yyyy-MM-dd-HH-mm 
$Outfile = "C:\Users\svc-MIM-admin\documents\" + $filedate + "-LogonsReport.csv"
$Header = "DC,SAMaccountName,lastLogon,LastLogonDate,lastLogonTimestamp,PasswordLastSet,pwdLastSet"
$header > $outfile
Foreach ($user in $Users) {
$ID = $user.samaccountname
Foreach ($DC in $DCs) {
$UP = Get-aduser $ID -Properties lastLogon,LastLogonDate,lastLogonTimestamp,PasswordLastSet,pwdLastSet -Server $DC.hostname
$lastLogon = $Null
$LastLogonDate = $Null
$lastLogonTimestamp = $Null
$PasswordLastSet = $Null
$pwdLastSet = $Null
$lastLogon = [datetime]::FromFileTime($UP.lastLogon) 
If ($lastLogon -ne $null ) {$lastLogon = $lastLogon|get-date -Format s }
$LastLogonDate = $UP.LastLogonDate 
If ($lastLogonDate -ne $null ) {$lastLogonDate = $lastLogonDate|get-date -Format s }
$lastLogonTimestamp = [datetime]::FromFileTime($UP.lastLogonTimestamp) |get-date -Format s
If ($lastLogonTimestamp -ne $null ) {$lastLogonTimestamp = $lastLogonTimestamp|get-date -Format s }
$PasswordLastSet = $UP.PasswordLastSet 
If ($PasswordLastSet -ne $null ) {$PasswordLastSet = $PasswordLastSet|get-date -Format s }
$pwdLastSet = [datetime]::FromFileTime($UP.pwdLastSet) 
If ($pwdLastSet -ne $null ) {$pwdLastSet = $pwdLastSet|get-date -Format s }
$Out = $DC.name + "," +$ID + "," + $lastLogon+ "," + $LastLogonDate+ "," + $lastLogonTimestamp+ "," + $PasswordLastSet+ "," + $pwdLastSet
$out >> $outfile
}
}
