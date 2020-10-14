import-module activedirectory

$users=import-csv c:\temp\move.txt

foreach ($user in $users) {

$U = $user.upn

$U1 = get-aduser -properties displayname,mail -filter 'displayname -eq $U'

$UPN = $U1.userprincipalname

$M = $U1.mail	

write-host $U";"$UPN";"$M

Set-msoluser –userprincipalname $Upn -UsageLocation za

set-msoluserlicense –userprincipalname $Upn –addlicenses  "syndication-account:EXCHANGESTANDARD"

New-MoveRequest -identity $U -Remote -RemoteHostName webmail.cullinan.co.za -RemoteCredential $RemCred -TargetDeliveryDomain “vb001437.onmicrosoft.com” -AcceptLargeDataLoss -BadItemLimit 1000

}

foreach ($user in $users) {

$Disp = $user.UPN

$UPN = get-aduser -properties Displayname,mail -filter 'Displayname -eq $Disp'

$U = $UPN.userprincipalname
$M = $UPN.mail

Write-host $user.UPN";"$U";"$M
}
