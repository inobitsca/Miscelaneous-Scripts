$servers = Import-Csv c:\temp\allServers.txt
$d = Get-Date
$D >> c:\temp\Serverscan.txt
$header = "dNSHostName,PingResult,IP,"
$header >> c:\temp\Serverscan.txt
$result >> c:\temp\Serverscan.txt
foreach ($server in $servers) {
$name = $server.dNSHostName
$W= ""
$P = Test-NetConnection $name  -WarningVariable W -WarningAction SilentlyContinue
If ($W -like "*name resolution*") {$R = "NoDNS"}
If ($W -like "*TimedOut*") {$R = "TimedOut"}
If ($P.PingSucceeded -eq "True") {$R = "Succeeded"}
#write-host $W
$result =  $name +","+ $R +","+ $p.RemoteAddress
$result >> c:\temp\Serverscan.txt
}