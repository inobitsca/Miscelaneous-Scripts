$wmi = Get-WmiObject -Class MIIS_Server -Namespace root\MicrosoftIdentityIntegrationServer
$cutoff = get-date '2020-06-01'
$start = get-date '2013-01-01'
while ($start -le $cutoff) { $wmi.ClearRuns($start); $start = $start.AddDays(1); }