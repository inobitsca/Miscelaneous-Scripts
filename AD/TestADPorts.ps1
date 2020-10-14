Write-host "Enter the IP of the DC you want to check Access to." -fore Cyan
$IP = read-host
Write ""
Write ""
$N = Resolve-DnsName $IP
$name = $n.namehost
Write-host "Checking connectivity from  to DC $name on IP $IP ." -fore cyan
Write ""
$TCP = tcping -n 1 $IP 389
if ($TCP -like "*1 succes*") {Write-host  $IP `t "Port 389  connection test successful" -fore Green}
else {Write-host  $IP `t "Port 389  connection test failed" -fore Red}
Write ""
$TCP = tcping -n 1 $IP 88
if ($TCP -like "*1 succes*") {Write-host  $IP `t "Port 88 connection test successful" -fore Green}
else {Write-host  $IP `t "Port 88 connection test failed" -fore Red}
Write ""
$TCP = tcping -n 1 $IP 135
if ($TCP -like "*1 succes*") {Write-host  $IP `t "Port 135  connection test successful" -fore Green}
else {Write-host  $IP `t "Port 135  connection test failed" -fore Red}
Write ""
$TCP = tcping -n 1 $IP 139
if ($TCP -like "*1 succes*") {Write-host  $IP `t "Port 139 connection test successful" -fore Green}
else {Write-host  $IP `t "Port 139 connection test failed" -fore Red}
Write ""
$TCP = tcping -n 1 $IP 445
if ($TCP -like "*1 succes*") {Write-host  $IP `t "Port 445  connection test successful" -fore Green}
else {Write-host  $IP `t "Port 445  connection test failed" -fore Red}
Write ""
