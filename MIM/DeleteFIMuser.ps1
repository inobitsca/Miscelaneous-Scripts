#Usage: DeleteFIMUser.PS1 AccountName
#----------------------------------------------------------------------------------------------------------
 set-variable -name URI -value "http://localhost:5725/resourcemanagementservice' " -option constant 
#----------------------------------------------------------------------------------------------------------
 function DeleteObject
 {
    PARAM($objectType, $objectId)
    END
    {
       $importObject = New-Object Microsoft.ResourceManagement.Automation.ObjectModel.ImportObject
       $importObject.ObjectType = $objectType
       $importObject.TargetObjectIdentifier = $objectId
       $importObject.SourceObjectIdentifier = $objectId
       $importObject.State = 2 
       $importObject | Import-FIMConfig -uri $URI
     } 
 }
#----------------------------------------------------------------------------------------------------------
 if(@(get-pssnapin | where-object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {add-pssnapin FIMAutomation}
 clear-host

 if($args.count -ne 1) {throw "Missing name parameter"}
 $objectName = $args[0]

 if(0 -eq [String]::Compare($objectName,"administrator", $true))
 {throw "You can't delete administrator"}
 if(0 -eq [String]::Compare($objectName,"Built-in Synchronization Account", $true))
 {throw "You can't delete Built-in Synchronization Account"}

 $exportObject = export-fimconfig -uri $URI -onlyBaseResources -customconfig "/Person[AccountName='$objectName']"

 if($exportObject -eq $null) {throw "L:Object not found"}
 $objectId = (($exportObject.ResourceManagementObject.ObjectIdentifier).split(":"))[2]

 DeleteObject -objectType "Person" `
              -objectId $objectId

 write-host "`nObject Deleted successfully`n" 
 Write-host "break"
#----------------------------------------------------------------------------------------------------------
 trap 
 { 
    $exMessage = $_.Exception.Message
    if($exMessage.StartsWith("L:"))
    {write-host "`n" $exMessage.substring(2) "`n" -foregroundcolor white -backgroundcolor darkblue}
    else {write-host "`nError: " $exMessage "`n" -foregroundcolor white -backgroundcolor darkred}
    Exit
 }
#----------------------------------------------------------------------------------------------------------
