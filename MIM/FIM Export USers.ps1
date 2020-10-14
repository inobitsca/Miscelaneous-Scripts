 set-variable -name URI -value "http://localhost:5725/resourcemanagementservice' " -option constant 
set-variable -name CSV -value "RegistredResetPassUsers.csv" -option constant

clear 

If(@(Get-PSSnapin | Where-Object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {Add-PSSnapin FIMAutomation} 

$WFDFilter = "/WorkflowDefinition[DisplayName='Password Reset AuthN Workflow']" 
$curObjectWFD = export-fimconfig -uri $URI –onlyBaseResources -customconfig ($WFDFilter) -ErrorVariable Err -ErrorAction SilentlyContinue 
$WFDObjectID = (($curObjectWFD.ResourceManagementObject.ResourceManagementAttributes | Where-Object {$_.AttributeName -eq "ObjectID"}).value).split(":")[2]
$Filter = "/Person[AuthNWFRegistered = '$WFDObjectID']"
$curObject = export-fimconfig -uri $URI –onlyBaseResources -customconfig ($Filter) -ErrorVariable Err -ErrorAction SilentlyContinue 

[array]$users = $null 
foreach($Object in $curObject) 
{
 $ResetPass = New-Object PSObject
 $UserDisplayName = (($Object.ResourceManagementObject.ResourceManagementAttributes | Where-Object {$_.AttributeName -eq "DisplayName"}).Value)
 $ResetPass | Add-Member NoteProperty "DisplayName" $UserDisplayName
 $Users += $ResetPass
}

$users | export-csv -path $CSV 