## This script requires TCPING.exe to be function.
# https://www.elifulkerson.com/projects/tcping.php 
$Target = read-host Please enter the target to check
$Port = Read-Host Please enter the port to check
$N = ""
$N = tcping -n 1  $target $port |findstr open
while (!$N) {
$N = tcping -n 1  $target $port |findstr open}
Write-host "$N" - fore green
[console]::beep(1000,375)
sleep -Milliseconds 375
[console]::beep(1200,375)
sleep -Milliseconds 375
[console]::beep(1300,375)
sleep -Milliseconds 375
[console]::beep(1400,1000)
