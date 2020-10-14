$newFarmAdministrator = "Transnet\TSSA-334849"
#-Host -Prompt 'Please provide the name of the new Farm Administrator in the form of DOMAIN\Username'

$caWebApp = Get-SPWebApplication -IncludeCentralAdministration | where-object {$_.DisplayName -eq "SharePoint Central Administration v4"} 
$caSite = $caWebApp.Sites[0] 
$caWeb = $caSite.RootWeb

$farmAdministrators = $caWeb.SiteGroups["Farm Administrators"] 
$farmAdministrators.AddUser($newFarmAdministrator, "", $newFarmAdministrator, "Configured via PowerShell")

$caWeb.Dispose() 
$caSite.Dispose()

$caDB = Get-SPContentDatabase -WebApplication $caWebApp 
Add-SPShellAdmin -Database $caDB -Username $newFarmAdministrator