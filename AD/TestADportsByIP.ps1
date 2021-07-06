Write-host "
Tests the ports required for connection to a DC for Trusts or other authentication, by domain name.
NOTE: This script requires TCPING.exe in the execution path.
https://www.elifulkerson.com/projects/tcping.php
https://download.elifulkerson.com//files/tcping/0.39/tcping.exe
" -fore Cyan

$DCIP = Read-host "Please enter the IP address you want to test"

Write-host "Testing AD Ports on IP $DCIP" -Fore Yellow

$DNS = tcping -n 1 $DCIP 53
if ($Kerb -like "*open*") {Write-host "Port 53 is open" -fore Green}
if ($Kerb -like "*no response*") {Write-host "Port 53 is not open" -fore Red}

$LDAP = tcping -n 1 $DCIP 389
if ($Ldap -like "*open*") {Write-host "Port 389 is open" -fore Green}
if ($Ldap -like "*no response*") {Write-host "Port 389 is not open" -fore red}

$LDAPS = tcping -n 1 $DCIP 636
if ($Ldaps -like "*open*") {Write-host "Port 636 is open" -fore Green}
if ($Ldap -like "*no response*") {Write-host "Port 636 is not open" -fore Red}

$Kerb = tcping -n 1 $DCIP 88
if ($Kerb -like "*open*") {Write-host "Port 88 is open" -fore Green}
if ($Kerb -like "*no response*") {Write-host "Port 88 is not open" -fore Red}

$RPC = tcping -n 1 $DCIP 135
if ($RPC -like "*open*") {Write-host "Port 135 is open" -fore Green}
if ($RPC -like "*no response*") {Write-host "Port 135 is not open" -fore Red}

$SMB1 = tcping -n 1 $DCIP 445
if ($SMB1 -like "*open*") {Write-host "Port 445 is open" -fore Green}
if ($SMB1 -like "*no response*") {Write-host "Port 445 is not open" -fore Red}

$SMB2 = tcping -n 1 $DCIP 139
if ($SMB2 -like "*open*") {Write-host "Port 139 is open" -fore Green}
if ($SMB2 -like "*no response*") {Write-host "Port 139 is not open" -fore Red}

$RDP = tcping -n 1 $DCIP 3389
if ($RDP -like "*open*") {Write-host "Port 3389 is open" -fore Green}
if ($RDP -like "*no response*") {Write-host "Port 3389 is not open" -fore Red}

$RDP = tcping -n 1 $DCIP 3268
if ($RDP -like "*open*") {Write-host "Port 3268 is open" -fore Green}
if ($RDP -like "*no response*") {Write-host "Port 3268 is not open" -fore Red}

Write-host ""

