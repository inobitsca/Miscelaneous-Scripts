
$DNS1 = "192.168.16.21"
$DNS2 = "10.9.0.13"
$Net = Get-NetAdapter
Foreach ($N in $net){
$DNS = $N |get-DnsClientServerAddress
$Check = $DNS.ServerAddresses |findstr .13
If (!$check) {
Write-Host "Found DNS Setting Error" -Fore Red
Set-DnsClientServerAddress -InterfaceIndex $N.ifindex -ServerAddresses ($DNS1,$DNS2)
$DNS = $N |get-DnsClientServerAddress
Write-Host "DNS setting changed to " $DNS.ServerAddresses -Fore Green
}
}
