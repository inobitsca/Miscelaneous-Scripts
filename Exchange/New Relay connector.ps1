$relay = Get-ReceiveConnector "srishub\mail relay"
$range = $relay.RemoteIPRanges

New-Receiveconnector -Name "InternalRelay" -RemoteIPRange ($range) -TransportRole "FrontendTransport" -Bindings ("192.168.30.74:25") -usage "Custom" -Server "SRPKLExchange"

Set-ReceiveConnector -identity "InternalRelay" -PermissionGroups "AnonymousUsers"

Get-ReceiveConnector "InternalRelay" | Add-ADPermission -User "NT Authority\ANONYMOUS LOGON" -ExtendedRights "Ms-Exch-SMTP-Accept-Any-Recipient"
