PARAM( 
	[string]$Principal = $(throw "`nMissing -Principal DOMAIN\FIM PasswordSet"), 
	$Computers = $(throw "`nMissing -Computers ('fimnode01','fimnode02')"))

# USAGE: 
#
# .\Set-FIM-DCOM.ps1 -Principal "DOMAIN\<group or username>" -Computers ('<server1>', '<server2>',...)
#
# EXAMPLE:
# .\Set-FIM-DCOM.ps1 -Principal "DOMAIN\FIM PasswordSet" -Computers ('fimsyncprimary', 'fimsyncstandby')
#
# Inspired by Karl Mitschke's post:
# http://unlockpowershell.wordpress.com/2009/11/20/script-remote-dcom-wmi-access-for-a-domain-user/

Write-Host "Set-FIM-DCOM - Updates DCOM Permissions for FIM Password Reset"
Write-Host "`tWritten by Brad Turner (bturner@ensynch.com)"
Write-Host "`tBlog: http://www.identitychaos.com"

function get-sid
{
 PARAM ($DSIdentity)
 $ID = new-object System.Security.Principal.NTAccount($DSIdentity)
 return $ID.Translate( [System.Security.Principal.SecurityIdentifier] ).toString()
}

$sid = get-sid $Principal

#MachineLaunchRestriction - Local Launch, Remote Launch, Local Activation, Remote Activation
$DCOMSDDLMachineLaunchRestriction = "A;;CCDCLCSWRP;;;$sid"

#MachineAccessRestriction - Local Access, Remote Access
$DCOMSDDLMachineAccessRestriction = "A;;CCDCLC;;;$sid"

#DefaultLaunchPermission - Local Launch, Remote Launch, Local Activation, Remote Activation
$DCOMSDDLDefaultLaunchPermission = "A;;CCDCLCSWRP;;;$sid"

#DefaultAccessPermision - Local Access, Remote Access
$DCOMSDDLDefaultAccessPermision = "A;;CCDCLC;;;$sid"

#PartialMatch
$DCOMSDDLPartialMatch = "A;;\w+;;;$sid"

foreach ($strcomputer in $computers)
{
 write-host "`nWorking on $strcomputer with principal $Principal ($sid):"
 # Get the respective binary values of the DCOM registry entries
 $Reg = [WMIClass]"\\$strcomputer\root\default:StdRegProv"
 $DCOMMachineLaunchRestriction = $Reg.GetBinaryValue(2147483650,"software\microsoft\ole","MachineLaunchRestriction").uValue
 $DCOMMachineAccessRestriction = $Reg.GetBinaryValue(2147483650,"software\microsoft\ole","MachineAccessRestriction").uValue
 $DCOMDefaultLaunchPermission = $Reg.GetBinaryValue(2147483650,"software\microsoft\ole","DefaultLaunchPermission").uValue
 $DCOMDefaultAccessPermission = $Reg.GetBinaryValue(2147483650,"software\microsoft\ole","DefaultAccessPermission").uValue

 # Convert the current permissions to SDDL
 write-host "`tConverting current permissions to SDDL format..."
 $converter = new-object system.management.ManagementClass Win32_SecurityDescriptorHelper
 $CurrentDCOMSDDLMachineLaunchRestriction = $converter.BinarySDToSDDL($DCOMMachineLaunchRestriction)
 $CurrentDCOMSDDLMachineAccessRestriction = $converter.BinarySDToSDDL($DCOMMachineAccessRestriction)
 $CurrentDCOMSDDLDefaultLaunchPermission = $converter.BinarySDToSDDL($DCOMDefaultLaunchPermission)
 $CurrentDCOMSDDLDefaultAccessPermission = $converter.BinarySDToSDDL($DCOMDefaultAccessPermission)

 # Build the new permissions
 write-host "`tBuilding the new permissions..."
 if (($CurrentDCOMSDDLMachineLaunchRestriction.SDDL -match $DCOMSDDLPartialMatch) -and ($CurrentDCOMSDDLMachineLaunchRestriction.SDDL -notmatch $DCOMSDDLMachineLaunchRestriction))
 {
   $NewDCOMSDDLMachineLaunchRestriction = $CurrentDCOMSDDLMachineLaunchRestriction.SDDL -replace $DCOMSDDLPartialMatch, $DCOMSDDLMachineLaunchRestriction
 }
 else
 {
   $NewDCOMSDDLMachineLaunchRestriction = $CurrentDCOMSDDLMachineLaunchRestriction.SDDL += "(" + $DCOMSDDLMachineLaunchRestriction + ")"
 }
  
 if (($CurrentDCOMSDDLMachineAccessRestriction.SDDL -match $DCOMSDDLPartialMatch) -and ($CurrentDCOMSDDLMachineAccessRestriction.SDDL -notmatch $DCOMSDDLMachineAccessRestriction))
 {
  $NewDCOMSDDLMachineAccessRestriction = $CurrentDCOMSDDLMachineAccessRestriction.SDDL -replace $DCOMSDDLPartialMatch, $DCOMSDDLMachineLaunchRestriction
 }
 else
 {
   $NewDCOMSDDLMachineAccessRestriction = $CurrentDCOMSDDLMachineAccessRestriction.SDDL += "(" + $DCOMSDDLMachineAccessRestriction + ")"
 }

 if (($CurrentDCOMSDDLDefaultLaunchPermission.SDDL -match $DCOMSDDLPartialMatch) -and ($CurrentDCOMSDDLDefaultLaunchPermission.SDDL -notmatch $DCOMSDDLDefaultLaunchPermission))
 {
   $NewDCOMSDDLDefaultLaunchPermission = $CurrentDCOMSDDLDefaultLaunchPermission.SDDL -replace $DCOMSDDLPartialMatch, $DCOMSDDLDefaultLaunchPermission
 }
 else
 {
   $NewDCOMSDDLDefaultLaunchPermission = $CurrentDCOMSDDLDefaultLaunchPermission.SDDL += "(" + $DCOMSDDLDefaultLaunchPermission + ")"
 }

 if (($CurrentDCOMSDDLDefaultAccessPermission.SDDL -match $DCOMSDDLPartialMatch) -and ($CurrentDCOMSDDLDefaultAccessPermission.SDDL -notmatch $DCOMSDDLDefaultAccessPermision))
 {
   $NewDCOMSDDLDefaultAccessPermission = $CurrentDCOMSDDLDefaultAccessPermission.SDDL -replace $DCOMSDDLPartialMatch, $DCOMSDDLDefaultAccessPermision
 }
 else
 {
   $NewDCOMSDDLDefaultAccessPermission = $CurrentDCOMSDDLDefaultAccessPermission.SDDL += "(" + $DCOMSDDLDefaultAccessPermision + ")"
 }

 # Convert SDDL back to Binary
 write-host "`tConverting SDDL back into binary form..."
 $DCOMbinarySDMachineLaunchRestriction = $converter.SDDLToBinarySD($NewDCOMSDDLMachineLaunchRestriction)
 $DCOMconvertedPermissionsMachineLaunchRestriction = ,$DCOMbinarySDMachineLaunchRestriction.BinarySD

 $DCOMbinarySDMachineAccessRestriction = $converter.SDDLToBinarySD($NewDCOMSDDLMachineAccessRestriction)
 $DCOMconvertedPermissionsMachineAccessRestriction = ,$DCOMbinarySDMachineAccessRestriction.BinarySD

 $DCOMbinarySDDefaultLaunchPermission = $converter.SDDLToBinarySD($NewDCOMSDDLDefaultLaunchPermission)
 $DCOMconvertedPermissionDefaultLaunchPermission = ,$DCOMbinarySDDefaultLaunchPermission.BinarySD

 $DCOMbinarySDDefaultAccessPermission = $converter.SDDLToBinarySD($NewDCOMSDDLDefaultAccessPermission)
 $DCOMconvertedPermissionsDefaultAccessPermission = ,$DCOMbinarySDDefaultAccessPermission.BinarySD

 # Apply the changes
 write-host "`tApplying changes..."
 if ($CurrentDCOMSDDLMachineLaunchRestriction.SDDL -match $DCOMSDDLMachineLaunchRestriction)
 {
   write-host "`t`tCurrent MachineLaunchRestriction matches desired value."
 }
 else
 {
   $result = $Reg.SetBinaryValue(2147483650,"software\microsoft\ole","MachineLaunchRestriction", $DCOMbinarySDMachineLaunchRestriction.binarySD)
   if($result.ReturnValue='0'){write-host "  Applied MachineLaunchRestricition complete."}
 }

 if ($CurrentDCOMSDDLMachineAccessRestriction.SDDL -match $DCOMSDDLMachineAccessRestriction)
 {
   write-host "`t`tCurrent MachineAccessRestriction matches desired value."
 }
 else
 {
   $result = $Reg.SetBinaryValue(2147483650,"software\microsoft\ole","MachineAccessRestriction", $DCOMbinarySDMachineAccessRestriction.binarySD)
   if($result.ReturnValue='0'){write-host "  Applied MachineAccessRestricition complete."}
 }

 if ($CurrentDCOMSDDLDefaultLaunchPermission.SDDL -match $DCOMSDDLDefaultLaunchPermission)
 {
   write-host "`t`tCurrent DefaultLaunchPermission matches desired value."
 }
 else
 {
   $result = $Reg.SetBinaryValue(2147483650,"software\microsoft\ole","DefaultLaunchPermission", $DCOMbinarySDDefaultLaunchPermission.binarySD)
   if($result.ReturnValue='0'){write-host "  Applied DefaultLaunchPermission complete."}
 }

 if ($CurrentDCOMSDDLDefaultAccessPermission.SDDL -match $DCOMSDDLDefaultAccessPermision)
 {
   write-host "`t`tCurrent DefaultAccessPermission matches desired value."
 }
 else
 {
   $result = $Reg.SetBinaryValue(2147483650,"software\microsoft\ole","DefaultAccessPermission", $DCOMbinarySDDefaultAccessPermission.binarySD)
   if($result.ReturnValue='0'){write-host "  Applied DefaultAccessPermission complete."}

 }
}
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