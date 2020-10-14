Add-PSSnapin FimAutomation
$ImportState = [Microsoft.ResourceManagement.Automation.ObjectModel.ImportState]
$importObject = New-Object Microsoft.ResourceManagement.Automation.ObjectModel.ImportObject
$importObject.ObjectType = “Person”
$importObject.TargetObjectIdentifier = $OID 
$importObject.SourceObjectIdentifier = $OID 
$importObject.State = $ImportState::Put

$importChange = New-Object Microsoft.ResourceManagement.Automation.ObjectModel.ImportChange
$importChange.Operation = 1
$importChange.AttributeName = “EmployeeEndDate” 
$importChange.AttributeValue = $DT1
$importChange.FullyResolved = 1
$importChange.Locale = “Invariant”
if ($importObject.Changes -eq $null) {$importObject.Changes = (,$importChange)}

Import-FIMConfig -Uri “http://localhost:5725” -ImportObject $importObject