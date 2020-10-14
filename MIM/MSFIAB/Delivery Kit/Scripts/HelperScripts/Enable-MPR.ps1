#-----------------------------------------------------------------------------------------------------------
 set-variable -name URI -value "http://localhost:5725/resourcemanagementservice" -option constant 
#-----------------------------------------------------------------------------------------------------------
 if($args.count -ne 1) {throw "MPR name missing!"}
 $mprName = $args[0]
 if(@(get-pssnapin | where-object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {add-pssnapin FIMAutomation}
 clear-host
 $curObject = export-fimconfig -uri $URI `
                               –onlyBaseResources `
                               -customconfig ("/ManagementPolicyRule[DisplayName='$mprName']")

 if($curObject -eq $null) {throw "MPR not found!"} 
 $objectType       = $curObject.ResourceManagementObject.ObjectType 
 $objectIdentifier = $curObject.ResourceManagementObject.ObjectIdentifier 

 $curAttribute = $curObject.ResourceManagementObject.ResourceManagementAttributes | `
                 Where-Object {$_.AttributeName -eq "Disabled"}
 
 if($curAttribute.Value -eq "False") {write-host "`nMPR is already enabled`n"}
 else
 {
    $importChange = New-Object Microsoft.ResourceManagement.Automation.ObjectModel.ImportChange
    $importChange.Operation = 1
    $importChange.AttributeName = "Disabled"
    $importChange.AttributeValue = "False"
    $importChange.FullyResolved = 1
    $importChange.Locale = "Invariant"
   
    $importObject = New-Object Microsoft.ResourceManagement.Automation.ObjectModel.ImportObject
    $importObject.ObjectType = $objectType
    $importObject.TargetObjectIdentifier = $objectIdentifier
    $importObject.SourceObjectIdentifier = $objectIdentifier
    $importObject.State = 1 
    $importObject.Changes = (,$importChange)
   
    $importObject | Import-FIMConfig -uri $URI
   
    write-host "`nMPR enabled successfully`n"
 }
#-----------------------------------------------------------------------------------------------------------
 trap 
 { 
    Write-Host "`nError: $($_.Exception.Message)`n" -foregroundcolor white -backgroundcolor darkred
    Exit 1
 }
#-----------------------------------------------------------------------------------------------------------
