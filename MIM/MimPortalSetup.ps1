Write-Host "Preparing SharePoint to host the MIM Portal" -Fore Yellow

Write-host "1.Creating Web Application" -Fore Green

$U = $env:computername + "." + $env:USERDNSDOMAIN
$URL = "http://" + $U
$URLp = $URL + ":82"


$MS =  $env:userdomain +"\MIMSharePoint"
$MA =  $env:userdomain + "\MIMAdmin"
$MB = $env:userdomain+ "\MIMBACKUPAdmin"


$dbManagedAccount = Get-SPManagedAccount -Identity $MS
New-SpWebApplication -Name "MIM Portal" -ApplicationPool "MIMAppPool" -ApplicationPoolAccount $dbManagedAccount -AuthenticationMethod "Kerberos" -Port 82 -URL $URL

Write-host "Completed"

Write-host "2.Creating a SharePoint Site Collection" -Fore Green

$t = Get-SPWebTemplate -compatibilityLevel 14 -Identity "STS#1"
$w = Get-SPWebApplication $URLp
New-SPSite -Url $w.Url -Template $t -OwnerAlias $MA -CompatibilityLevel 14 -Name "MIM Portal" -SecondaryOwnerAlias $MB
$s = SpSite($w.Url)
$s.AllowSelfServiceUpgrade = $false
$s.CompatibilityLevel

Write-host "Completed"

Write-host "3.Disabling SharePoint Server-Side Viewstate and the Health Analysis SharePoint task" -fore Yellow

$contentService = [Microsoft.SharePoint.Administration.SPWebService]::ContentService;
$contentService.ViewStateOnServer = $false;
$contentService.Update();
Get-SPTimerJob hourly-all-sptimerservice-health-analysis-job | disable-SPTimerJob

Write-host "Completed"

Write-Host "The MIM Portal has been deployed on the following URL:" -fore green  
Write-host $URLp -fore Cyan