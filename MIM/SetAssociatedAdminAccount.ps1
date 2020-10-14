Add-PSSnapin FIMAutomation
$uri = "http://localhost:5725/resourcemanagementservice"

#$AccountName = $fimwf.WorkflowDictionary.AccountName
#$Email = $fimwf.WorkflowDictionary.OTPEmail
#$Domain = "AD"
$ObId = ""
$ManId = ""
$AccountName = "ADM-AmyRu"

$exportObject1 = export-fimconfig -uri $URI -onlyBaseResources  -customconfig ("/Person[AccountName='$AccountName']")

$Attrib1 = $exportObject1.ResourceManagementObject.ResourceManagementAttributes					

foreach ($a in $Attrib1) { 
if($a.AttributeName -eq "Manager") { $ManId = $a.value}
if($a.AttributeName -eq "ObjectID") { $ObId = $a.value}
}

Write-host $ObId
Write-host $ManId
$obid = $obid -replace "urn:uuid:" ,""
$Manid = $Manid -replace "urn:uuid:" ,""
$exportObject =  ""
$exportObject = export-fimconfig -uri $URI -onlyBaseResources -customconfig ("/Person[ObjectID='$ManId']")
$attrib = ""
$Attrib = $exportObject.ResourceManagementObject.ResourceManagementAttributes				
$attrib |FT

			
$importChange = New-Object Microsoft.ResourceManagement.Automation.ObjectModel.ImportChange
$importChange.Operation = 1
$importChange.AttributeName = "AssociatedAdminAccount"
$importChange.AttributeValue = $Obid
$importChange.FullyResolved = 1
$importChange.Locale = "Invariant"
$importObject = New-Object Microsoft.ResourceManagement.Automation.ObjectModel.ImportObject
$importObject.ObjectType = $exportObject.ResourceManagementObject.ObjectType
$importObject.TargetObjectIdentifier = $exportObject.ResourceManagementObject.ObjectIdentifier
$importObject.SourceObjectIdentifier = $exportObject.ResourceManagementObject.ObjectIdentifier
$importObject.State = 1 
$importObject.Changes = (,$importChange)
write-host " -Writing Account information AssociatedAdminAccount = $Obid"
$importObject | Import-FIMConfig -uri $URI -ErrorVariable Err -ErrorAction SilentlyContinue
if($Err){throw $Err}
Write-Host "Success!"

