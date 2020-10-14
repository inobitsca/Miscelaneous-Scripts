$VirtualSwitchService = get-wmiobject -class "Msvm_VirtualSwitchManagementService" -namespace "root\virtualization" 
$ReturnObject = $VirtualSwitchService.CreateSwitch([guid]::NewGuid().ToString(), "FIAB-Private", "1024","") 

#Create New Virtual Switch 
#$CreatedSwitch = [WMI]$ReturnObject.CreatedVirtualSwitch

$VM_Service = get-wmiobject –namespace root\virtualization –class Msvm_VirtualSystemManagementService

$ListOfFolders =  dir "C:\MSFIAB\VHDs" | where { $_.PSIsContainer} | select FullName
foreach ($f in $ListOfFolders) 
{
    $Folder = $f.FullName
    $Status  = $VM_Service.ImportVirtualSystem($Folder,$True)
    If ($Status.ReturnValue -eq 0) { write-host "Operation Successful"; exit} 
    #if ( $status.ReturnValue -eq 4096) { $JobStatus = $Status.Job.JobState; while ($JobStatus -ne 0) { sleep(1) } } 
}
