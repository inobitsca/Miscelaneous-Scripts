$users = import-csv .\GetArchiveGuid.csv

foreach ($user in $users) { 
$MB = get-mailbox $user.upn
$AG = $MB.ArchiveGuid
$PS = $MB.PrimarySmtpAddress
$SA = $PS.replace("inobits.com","inobitsza.onmicrosoft.com")
$Alias = $mb.alias
Write-host $user.upn $AG $PS $SA $Alias
}
