PARAM([int]$dayDiff, [string]$exportDirectory)

$dateDelete = Get-Date

#if the dayDiff parameter is passed, subtract it from the current day.
If($dayDiff -ne 0)
{
$dateDelete = $dateDelete.AddDays(-$dayDiff)
}
Else
{
$dateDelete = $dateDelete.AddDays(1)
}

#if the exportDirectory parameter is passed, save the run history to that directory
If($exportDirectory -ne “”)
{
Write-Host “Exporting full run history.”

$lstManagementAgent = @(get-wmiobject -class “MIIS_ManagementAgent” -namespace “root\MicrosoftIdentityIntegrationServer” -computer “.”)
$runDetails = $lstManagementAgent[0].RunDetails().ReturnValue

$doc = New-Object System.Xml.XmlDocument
$doc.LoadXml($runDetails)
$dateNow = Get-Date -format “yyyyMMddHHmm”

$filePathName = $exportDirectory + $dateNow + “.xml”
$doc.Save($filePathName)

Write-Host “Successfully exported run history to: ” $filePathName
}

#finally, delete the run history:
#Write-Host “Deleting run history earlier than:” $dateDelete.toString(‘MM/dd/yyyy’)

#$lstSrv = @(get-wmiobject -class “MIIS_SERVER” -namespace “root\MicrosoftIdentityIntegrationServer” -computer “.”)
#Write-Host “Result: ” $lstSrv[0].ClearRuns($dateDelete.toString(‘yyyy-MM-dd’)).ReturnValue

#——————————————————————————————————————–
Trap
{
Write-Host “Error: $($_.Exception.Message)” -foregroundcolor white -backgroundcolor darkred
Exit
}
#—————————————————————————————