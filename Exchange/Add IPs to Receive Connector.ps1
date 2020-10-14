$IPs = import-csv c:\temp\IPs.txt
foreach ($IP in $IPs) {
$RecvConn = Get-ReceiveConnector "InternalRelay"
$Range = $RecvConn.RemoteIPRanges
If ("172.18.7.101" -notin $Range ) {
Write-host "Adding value" $IP
$RecvConn.RemoteIPRanges += $IP.IP
Set-ReceiveConnector "InternalRelay" -RemoteIPRanges $RecvConn.RemoteIPRanges}
Else {Write-host Value $IP.IP is already present}
}
