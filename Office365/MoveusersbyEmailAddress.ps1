$users=import-csv c:\temp\mig.txt
import-module activedirectory

foreach ($user in $users) {

$mail = "*" + $user.upn + "*"

$UPN = get-aduser -properties proxyaddresses -filter 'proxyaddresses -like $mail'

$U = $UPN.userprincipalname

#$Dis =$UPN.displayname

write-host $U $user.UPN

set-msoluser –userprincipalname $U -UsageLocation za

set-msoluserlicense –userprincipalname $U –addlicenses  "syndication-account:EXCHANGESTANDARD"

#New-MoveRequest -identity $U -Remote -RemoteHostName webmail.cullinan.co.za -RemoteCredential $RemCred -TargetDeliveryDomain “vb001437.onmicrosoft.com” -AcceptLargeDataLoss -BadItemLimit 1000


}


c:\temp\UPNsFromEmailAddress.ps1