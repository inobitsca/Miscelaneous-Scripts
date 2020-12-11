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

#New-MoveRequest -identity $U -Remote -RemoteHostName autodiscover.medikredit.co.za -RemoteCredential $RemCred -TargetDeliveryDomain “medikredit.co.za” -AcceptLargeDataLoss -BadItemLimit 1000


}


c:\temp\UPNsFromEmailAddress.ps1


New-MoveRequest -identity mashudum@medikredit.co.za -Remote -RemoteHostName autodiscover.medikredit.co.za -RemoteCredential $credential -TargetDeliveryDomain “medikredit.co.za” -AcceptLargeDataLoss -BadItemLimit 1000
Bus-Apps-Accpac-Prod-RG