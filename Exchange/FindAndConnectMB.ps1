CLS
Write-host "Starting script to reconnect a missing linked mailbox."  -fore Cyan
sleep -s 1
$Conf = "n"
$Con = "n"
Write-host "Please wait while we look for disconnected mailboxes...." -fore Yellow

$SYNEXCDB04  = Get-MailboxStatistics -database SYNEXCDB04 | where {$_.DisconnectReason  -ne $null }
$SYNEXCDB03  = Get-MailboxStatistics -database SYNEXCDB03 | where {$_.DisconnectReason  -ne $null }
$SYNEXCDB02  = Get-MailboxStatistics -database SYNEXCDB02 | where {$_.DisconnectReason  -ne $null }
$SYNEXCDB01  = Get-MailboxStatistics -database SYNEXCDB01 | where {$_.DisconnectReason  -ne $null }

$DB01Count = $SYNEXCDB01 | measure |select count
$DB02Count = $SYNEXCDB02 | measure |select count
$DB03Count = $SYNEXCDB03 | measure |select count
$DB03Count = $SYNEXCDB03 | measure |select count

$TotalMB = $DB01Count.count + $DB02Count.count + $DB03Count.count + $DB04Count.count 
Write-host ""
Write-host ""
Write-host "We found $TotalMB disconnected mailboxes" -fore Cyan
sleep -s 2
$SYNEXCDB01 |fl DisplayName
$SYNEXCDB02 |fl DisplayName
$SYNEXCDB03 |fl DisplayName
$SYNEXCDB04 |fl DisplayName

Write-host ""
Write-host "If the mailbox you want to reconnect is not shown above, then it is not a disconnected mailbox and may have been deleted."  -fore Cyan
Write-host "Do you want to continue? y/n"
$x = Read-host

if ($X -eq "n") {exit}

[console]::ForegroundColor = "Green"
Write-host ""
Write-host ""
Write-host ""
Write-host ""
Write-host "Please enter the credentials for the IIH domain" -Fore Yellow
$SourceCredentials  = get-credential
Write-host ""
Write-host ""
Write-host ""
Write-host "Please enter the account you want to link to E.G. user@idwala.co.za" 
$user = read-host

Write-host ""
Write-host ""
while ($conf -ne "y") {
write-host "Please enter a part of the missing mailbox name E.G. Mike or press enter to show all disconnected mailboxes" 
$PN1  = read-host 
$PN = "*" + $PN1 + "*"
[console]::ForegroundColor = "White"
$SYNEXCDB01 |where {$_.displayname -like $PN} |fl DisplayName,Database,MailboxGuid,disc*
$SYNEXCDB02 |where {$_.displayname -like $PN} |fl DisplayName,Database,MailboxGuid,disc*
$SYNEXCDB03 |where {$_.displayname -like $PN} |fl DisplayName,Database,MailboxGuid,disc*
$SYNEXCDB04 |where {$_.displayname -like $PN} |fl DisplayName,Database,MailboxGuid,disc*
[console]::ForegroundColor = "Green"
Write-host "Did you find the mailbox you want to connect? y/n" 
$Conf = Read-host
}

$DB = read-host "Please paste the database name here"
$G =  read-host "Please paste the MailboxGuid here"

Write-host "Do you want to connect the mailbox with Guid $G to the user $user ? y/n"  -fore yellow
$Con = Read-Host 

if ($con -eq "y") {
Connect-Mailbox -Identity $G -Database $DB -LinkedDomainController IDWDC01ADC02.idwala.co.za -LinkedMasterAccount $user -LinkedCredential $SourceCredentials -confirm:$False
}
 Write-host Script ended -fore Cyan
[console]::ForegroundColor = "White"