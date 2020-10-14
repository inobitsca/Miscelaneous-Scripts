#----------------------------------------------------------------------------------------------------------
  Set-Variable -Name URI       -Value "http://localhost:5725/resourcemanagementservice" -Option Constant 
 <#Set-Variable -Name SetName   -Value "Test Set"                                        -Option Constant
 Set-Variable -Name SetFilter -Value "/Person[EmployeeType = 'Contractor']"            -Option Constant #>
#----------------------------------------------------------------------------------------------------------
 $sets = Import-csv c:\scripts\sets.csv 
 
 Foreach ($set in $sets)
 {
 $setname = $set.name
 $Filter1 = $set.Criterior
 $SetFilter = "/Person[OfficeLocation = '" + $Filter1 + "']"
 
 Function SetAttribute
 {
    Param($object, $attributeName, $attributeValue)
    End
    {
        $importChange = New-Object Microsoft.ResourceManagement.Automation.ObjectModel.ImportChange
        $importChange.Operation = 1
        $importChange.AttributeName = $attributeName
        $importChange.AttributeValue = $attributeValue
        $importChange.FullyResolved = 1
        $importChange.Locale = "Invariant"
        If ($object.Changes -eq $null) {$object.Changes = (,$importChange)}
        Else {$object.Changes += $importChange}
    }
} 
#----------------------------------------------------------------------------------------------------------
 Function CreateObject
 {
    Param($objectType)
    End
    {
       $newObject = New-Object Microsoft.ResourceManagement.Automation.ObjectModel.ImportObject
       $newObject.ObjectType = $objectType
       $newObject.SourceObjectIdentifier = [System.Guid]::NewGuid().ToString()
       $newObject
     } 
 }
#----------------------------------------------------------------------------------------------------------
 If(@(Get-PSSnapin | Where-Object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {Add-PSSnapin FIMAutomation}
 Clear-Host
 $exportObject = export-fimconfig -uri $URI `
                                  –onlyBaseResources `
                                  -customconfig "/Set[DisplayName='$SetName']"
 
 If($exportObject) {Throw "L:Set already exists: $SetName"}

 $newSet = CreateObject -objectType "Set"
 SetAttribute -object $newSet `
              -attributeName  "DisplayName" `
              -attributeValue $SetName 

 $filter = "<Filter xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" " + `
           "xmlns:xsd=""http://www.w3.org/2001/XMLSchema"" " + `
           "Dialect=""http://schemas.microsoft.com/2006/11/XPathFilterDialect"" " + `
           "xmlns=""http://schemas.xmlsoap.org/ws/2004/09/enumeration"">" + `
           $SetFilter + `
           "</Filter>" 

 SetAttribute -object $newSet `
              -attributeName  "Filter" `
              -attributeValue $filter 
#----------------------------------------------------------------------------------------------------------
 $newSet | Import-FIMConfig -uri $URI
 Write-Host "`nSet created successfully`n"
#----------------------------------------------------------------------------------------------------------
 Trap 
 { 
    $exMessage = $_.Exception.Message
    if($exMessage.StartsWith("L:"))
    {Write-Host "`n" $exMessage.substring(2) "`n" -foregroundcolor white -backgroundcolor darkblue}
    else {Write-Host "`nError: " $exMessage "`n" -foregroundcolor white -backgroundcolor darkred}
    Exit 1
 }
 }