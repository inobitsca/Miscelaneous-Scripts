PARAM(
	[string]$Principal = $(throw "`nMissing -Principal DOMAIN\FIM PasswordSet"), 
	$Computers = $(throw "`nMissing -Computers ('fimnode01','fimnode02')"))	

# USAGE: 
# 
# .\Set-FIM-WMI.ps1 -Principal "DOMAIN\<group or username>" -Computers ('<server1>', '<server2>',...) 
# 
# EXAMPLE: 
# .\Set-FIM-WMI.ps1 -Principal "DOMAIN\FIM PasswordSet" -Computers ('fimsyncprimary', 'fimsyncstandby')
#
# Inspired by Karl Mitschke's post:
# http://unlockpowershell.wordpress.com/2009/11/20/script-remote-dcom-wmi-access-for-a-domain-user/

Write-Host "Set-FIM-WMI - Updates WMI Permissions for FIM Password Reset"
Write-Host "`tWritten by Brad Turner (bturner@ensynch.com)"
Write-Host "`tBlog: http://www.identitychaos.com"

function get-sid
{
 PARAM ($DSIdentity)
 $ID = new-object System.Security.Principal.NTAccount($DSIdentity)
 return $ID.Translate( [System.Security.Principal.SecurityIdentifier] ).toString()
}

$sid = get-sid $Principal

#WMI Permission - Enable Account, Remote Enable for This namespace and subnamespaces 
$WMISDDL = "A;CI;CCWP;;;$sid" 

#PartialMatch
$WMISDDLPartialMatch = "A;\w*;\w+;;;$sid"

foreach ($strcomputer in $computers)
{
  write-host "`nWorking on $strcomputer..."
  $security = Get-WmiObject -ComputerName $strcomputer -Namespace root/cimv2 -Class __SystemSecurity
  $binarySD = @($null)
  $result = $security.PsBase.InvokeMethod("GetSD",$binarySD)

  # Convert the current permissions to SDDL 
  write-host "`tConverting current permissions to SDDL format..."
  $converter = new-object system.management.ManagementClass Win32_SecurityDescriptorHelper
  $CurrentWMISDDL = $converter.BinarySDToSDDL($binarySD[0])

  # Build the new permissions 
  write-host "`tBuilding the new permissions..."
  if (($CurrentWMISDDL.SDDL -match $WMISDDLPartialMatch) -and ($CurrentWMISDDL.SDDL -notmatch $WMISDDL))
  {
   $NewWMISDDL = $CurrentWMISDDL.SDDL -replace $WMISDDLPartialMatch, $WMISDDL
  }
  else
  {
   $NewWMISDDL = $CurrentWMISDDL.SDDL += "(" + $WMISDDL + ")"
  }

  # Convert SDDL back to Binary 
  write-host `t"Converting SDDL back into binary form..."
  $WMIbinarySD = $converter.SDDLToBinarySD($NewWMISDDL)
  $WMIconvertedPermissions = ,$WMIbinarySD.BinarySD
 
  # Apply the changes
  write-host "`tApplying changes..."
  if ($CurrentWMISDDL.SDDL -match $WMISDDL)
  {
    write-host "`t`tCurrent WMI Permissions matches desired value."
  }
  else
  {
   $result = $security.PsBase.InvokeMethod("SetSD",$WMIconvertedPermissions) 
   if($result='0'){write-host "`t`tApplied WMI Security complete."}
  }
}