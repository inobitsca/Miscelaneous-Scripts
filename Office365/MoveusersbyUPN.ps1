$users=import-csv c:\temp\mig.txt
import-module activedirectory

foreach ($user in $users) {

$U = $user.UPN

write-host $U

set-msoluser –userprincipalname $U -UsageLocation za

set-msoluserlicense –userprincipalname $U –addlicenses  "syndication-account:EXCHANGESTANDARD"

New-MoveRequest -identity $U -Remote -RemoteHostName pfsm.premierfoods.com -RemoteCredential $RemCred -TargetDeliveryDomain “premierfoods.com” -AcceptLargeDataLoss -BadItemLimit 1000


}

