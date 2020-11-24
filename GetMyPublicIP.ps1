$r = 'https://api.ipify.org/' 
$IPA = Invoke-WebRequest $r
$IP = $IPA.content
Write-host "Your Public IP is: $IPA "-fore Green
