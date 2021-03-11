$relay = Get-ReceiveConnector "srishub\mail relay"
$range = $relay.RemoteIPRanges

New-Receiveconnector -Name "InternalRelay" -RemoteIPRange ($range) -TransportRole "FrontendTransport" -Bindings ("172.16.200.6:25") -usage "Custom" -Server "MKJHBEXC001.medikredit.co.za"

Set-ReceiveConnector -identity "InternalRelay" -PermissionGroups "AnonymousUsers"

Get-ReceiveConnector "MKJHBEXC001\MDKGateway" | Add-ADPermission -User "NT Authority\ANONYMOUS LOGON" -ExtendedRights "Ms-Exch-SMTP-Accept-Any-Recipient"
