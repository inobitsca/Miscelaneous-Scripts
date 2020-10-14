#Get OneDrive usage in GB
#Requires Global Admin RightSharePoint
#Requires SharePoint Online Management Shell and MSOnline powershell module.

Connect-SPOService -Url https://premierfoodsonline-admin.sharepoint.com
connect-msolservice


$users = Get-MsolUser -MaxResults 5000 |where {$_.islicensed -eq $True}
$D = get-date -Format yyyy-MM-dd
$outfile = "C:\temp\PremOneDriveUsage-" + $D + ".csv"
$M = $users|measure
$count = $M.count
$TCount = $Count
	$Head = "Owner" + "," + "Owner UPN" + "," + "Usage (GB)"	 + "," + "Onedrive URL"
	$head > $outfile
	$count = 1
foreach($user in $Users){
$SPUPN = $user.UserPrincipalName -replace "@","_"  -replace ".com" , "_com"
$URL = "https://premierfoodsonline-my.sharepoint.com/personal/" + $SPUPN
$sc = Get-SPOSite $url -Detailed -ErrorAction SilentlyContinue | select url, storageusagecurrent, Owner
$usage = $sc.StorageUsageCurrent / 1024 
$URL2  = $sc.url
$Owner =$sc.Owner
$DN =  $user.displayname 
$out = $DN + "," + $Owner + "," + $usage + "," + $URL 
Write-host "Processing record $count of $Tcount for user $DN" -Fore Yellow
Write-host "OneDrive URL - $URL2" -Fore Cyan
$out >> $outfile
$Count = $count + 1
 }


