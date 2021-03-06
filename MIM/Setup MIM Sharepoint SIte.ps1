New-SPManagedAccount ##Will prompt for new account enter inobitsza\mimpool 
$dbManagedAccount = Get-SPManagedAccount -Identity inobitsza\mimpool
New-SpWebApplication -Name "MIM Portal" -ApplicationPool "MIMAppPool" -ApplicationPoolAccount $dbManagedAccount -AuthenticationMethod "Kerberos" -Port 80 -URL http://mim.inobitsza.com


$t = Get-SPWebTemplate -compatibilityLevel 14 -Identity "STS#1"
$w = Get-SPWebApplication http://mim.inobitsza.com/
New-SPSite -Url $w.Url -Template $t -OwnerAlias inobitsza\mimadmin -CompatibilityLevel 14 -Name "MIM Portal"
$s = SpSite($w.Url)
$s.CompatibilityLevel
 
 
$siteUrl = "http://mim.inobitsza.com"; # Change this one!
$site = Get-SPSite $siteUrl;
$site.AllowSelfServiceUpgradeEvaluation = $false;
$site.AllowSelfServiceUpgrade = $false;

$contentService = [Microsoft.SharePoint.Administration.SPWebService]::ContentService;
$contentService.ViewStateOnServer = $false;
$contentService.Update();

#################################################
# Add a new Farm Administrator
#################################################
Add-PSSnapin *SharePoint* -erroraction SilentlyContinue
Write-Host
$newFarmAdmin = Read-Host -Prompt 'Enter the new Farm Administrator (i.e. DOMAIN\Username): '
Write-Host
$webApp = Get-SPWebApplication -IncludeCentralAdministration | where-object {$_.DisplayName -eq "SharePoint Central Administration v4"}
$site = $webApp.Sites[0];
$Web = $site.RootWeb;
$farmAdministrators = $web.SiteGroups["Farm Administrators"];
try {
   $farmAdministrators.AddUser($newFarmAdmin, "", $newFarmAdmin, "");
   $contentDB = Get-SPContentDatabase -WebApplication $webApp
   Add-SPShellAdmin -Database $contentDB -Username $newFarmAdmin
   Write-Host "Completed Succesfully!"
} catch {
   Write-Host 'Error: Failed to add user.' -ForegroundColor Red
   Write-Host ('Reason: ' + $_)  -ForegroundColor Red
}
$web.Dispose();
$site.Dispose();