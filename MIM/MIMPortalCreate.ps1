


$dbManagedAccount = Get-SPManagedAccount -Identity Netsurit\MIMSharePoint
New-SpWebApplication -Name "MIM Portal" -ApplicationPool "MIMAppPool" -ApplicationPoolAccount $dbManagedAccount -AuthenticationMethod "Kerberos" -Port 82 -URL http://mimportal.netsurit.com




$t = Get-SPWebTemplate -compatibilityLevel 14 -Identity "STS#1"
$w = Get-SPWebApplication http://mim.netsurit.com:82
New-SPSite -Url $w.Url -Template $t -OwnerAlias Netsurit\MIMAdmin -CompatibilityLevel 14 -Name "MIM Portal" -SecondaryOwnerAlias Netsurit\MIMBackupAdmin
$s = SpSite($w.Url)
$s.AllowSelfServiceUpgrade = $false
$s.CompatibilityLevel


$contentService = [Microsoft.SharePoint.Administration.SPWebService]::ContentService;
$contentService.ViewStateOnServer = $false;
$contentService.Update();
Get-SPTimerJob hourly-all-sptimerservice-health-analysis-job | disable-SPTimerJob


