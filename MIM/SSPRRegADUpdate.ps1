Import-module activedirectory

set-variable -name URI -value "http://localhost:5725/resourcemanagementservice' " -option constant
set-variable -name CSV -value "RegistredResetPassUsers.csv" 

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

 $UserAccountName = (($Object.ResourceManagementObject.ResourceManagementAttributes | Where-Object {$_.AttributeName -eq "AccountName"}).Value)

 $ResetPass | Add-Member NoteProperty "AccountName" $UserAccountName

 $Users += $ResetPass
 $User
}

foreach ($user in $users)     {
Set-ADUser $user.AccountName -Add @{extensionAttribute1="Registered"}
$user.AccountName
}