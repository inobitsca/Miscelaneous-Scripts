$Suffix = "@medikredit.mail.onmicrosoft.com"
$MBs = Get-RemoteMailbox #|where {$_.RemoteRoutingAddress -notlike "*onmicrosoft.com"}
Foreach ($MB in $MBs) {
$A = $MB.alias
$RR = "SMTP:" + $A + $Suffix
Set-RemoteMailbox $A -RemoteRoutingAddress $RR -whatif
}
