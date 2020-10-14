$data = @() 

$NetLogs = Get-WmiObject Win32_NetworkLoginProfile 

foreach ($NetLog in $NetLogs) { 
if ($NetLog.LastLogon -match "(\d{14})") { 
$row = "" | Select Name,LogonTime 
$row.Name = $NetLog.Name 
$row.LogonTime=[datetime]::ParseExact($matches[0], "yyyyMMddHHmmss", $null) 
$data += $row 
} 
} 

$data