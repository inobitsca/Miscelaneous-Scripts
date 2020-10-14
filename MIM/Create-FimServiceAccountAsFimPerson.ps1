###
### Get the FIM Service Account 
###
$fimService = Get-WmiObject win32_service -Filter "name='FIMService'"  
$fimServiceServiceAccount = $fimService.StartName -Split '\\'

###
### Load the FIM PowerShell Module
###
if (-not (Get-Module FimPowerShellModule))
{
    Write-Verbose "Loading the FIM Service Config Module from: C:\CodePlex\FimPowerShellModule"
	if (-not (Test-Path C:\CodePlex\FimPowerShellModule\FimPowerShellModule.psm1))
	{
		Throw "This script requires the FimPowerShellModule from http://fimpowershellmodule.codeplex.com"
	}
    Import-Module C:\CodePlex\FimPowerShellModule\FimPowerShellModule.psm1 -Verbose:$false
}

###
### Create the User in FIM
###
Write-Verbose ("Searching FIM for an existing FIM Person object with the Service Account's logon name: '{0}' " -F $fimServiceServiceAccount[1])
$existingFimUser = Export-FIMConfig -OnlyBaseResources -CustomConfig ("/Person[AccountName='{0}']" -F  $fimServiceServiceAccount[1]) |
    Convert-FimExportToPSObject

if (-not $existingFimUser)  
{     
	Write-Verbose ("Creating a new FIM Person object with the Service Account's logon name: '{0}' " -F $fimServiceServiceAccount[1])
 	New-FimImportObject -State Create -ObjectType Person -Changes @{
        AccountName = $fimServiceServiceAccount[1]
        DisplayName = $fimServiceServiceAccount[1]
        Domain      = $fimServiceServiceAccount[0]
        ObjectSID   = (Get-ObjectSid -AccountName $fimServiceServiceAccount[1])
    } -ApplyNow
}
else
{
    Write-Warning ("FIM Person with AccountName '{0}' already exists." -F $fimServiceServiceAccount[1])
}

###
### Add the user to the Administrators Set
###
Write-Verbose ("Adding FIM Service Account '{0}' to the FIM Administrators Set" -F $fimServiceServiceAccount[1])
New-FimImportObject -State Put -ObjectType Set -AnchorPairs @{DisplayName='Administrators'} -Changes @(
    New-FimImportChange -Operation Add -AttributeName ExplicitMember -AttributeValue ('Person','AccountName',$fimServiceServiceAccount[1])
) -ApplyNow
