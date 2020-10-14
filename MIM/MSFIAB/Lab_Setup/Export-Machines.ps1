## Connect to the Virtual machine Management Service
$VM_Service = get-wmiobject –namespace root\virtualization –class Msvm_VirtualSystemManagementService

Write-host "Started $(Date)"
## Get reference to a VM to be exported
"FIABDC01", "FIABFIM01", "FIABPC01" | % `
{
	$Core = get-wmiobject -namespace root\virtualization -class Msvm_ComputerSystem -filter " ElementName = '$($_)' "

	## call the Export method
	Write-Host "Start Exporting $_"
	$status = $VM_Service.ExportVirtualSystem($Core.__PATH, $True, "F:\Export")
	If ($Status.ReturnValue -eq 0) 
	{ 
		write-host "Export of $($_) initiated successfully"
		exit
	} 
    else
    {
        Write-Host "Error $($Status.ReturnValue)"
    }
}
Write-host "Ended $(Date)"
#if ( $status.ReturnValue -eq 4096) 
#{ 		
#    $JobStatus = $Status.Job.JobState;		
#    while ($JobStatus -ne 0) 
#    { 
#        sleep(1) 
#    } 
#}