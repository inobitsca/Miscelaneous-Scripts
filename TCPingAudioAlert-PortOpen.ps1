## This script requires TCPING.exe to be function.
# https://www.elifulkerson.com/projects/tcping.php 
$Target = read-host Please enter the target to check
$Port = Read-Host Please enter the port to check
$N = ""
$N = tcping -n 1  $target $port |findstr open

$T=600
while ($T -gt 0) {
$N = tcping -n 1  $target $port |findstr open
if ($N){Write-host "$N" -fore green
[console]::beep(1000,375)
sleep -Milliseconds 1000}
If (!$N) {
$N = tcping -n 1  $target $port |findstr open
Write-host "No response from $target on port $Port" -fore Red
[console]::beep(1400,100)
sleep -Milliseconds 2000
$T = $T -1
}}