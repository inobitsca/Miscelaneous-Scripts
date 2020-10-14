$users=import-csv c:\temp\disabled.txt
import-module activedirectory

foreach ($user in $users) {

$U = $user.alias

write-host $U 

New-MoveRequest -identity $U -Remote -RemoteHostName webmail.pureconsulting.co.za -RemoteCredential $RemCred -TargetDeliveryDomain “pureconsult.onmicrosoft.com” -AcceptLargeDataLoss -BadItemLimit 1000 -largeitemliimit 1000


}
