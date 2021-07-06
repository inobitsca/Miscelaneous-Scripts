$r = 'https://api.ipify.org/' 
$IPA = Invoke-WebRequest $r 
Write-host "Your Public IP is: $IPA "-fore Green
#