################################################################################
# PowerShell routine to move Windows 7 Computers into OU structure based on IP #
################################################################################

# Requires Active Directory 2008 R2 and the PowerShell ActiveDirectory module

#####################
# Environment Setup #
#####################

#Add the Active Directory PowerShell module
Import-Module ActiveDirectory

#Set the threshold for an "old" computer which will be moved to the Disabled OU
$old = (Get-Date).AddDays(-60) # Modify the -60 to match your threshold 

#Set the threshold for an "very old" computer which will be deleted
$veryold = (Get-Date).AddDays(-90) # Modify the -90 to match your threshold 


##############################
# Set the Location IP ranges #
##############################

$Site1IPRange = "\b(?:(?:192)\.)" + "\b(?:(?:168)\.)" + "\b(?:(?:1)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" # 192.168.1.0/24
$Site2IPRange = "\b(?:(?:192)\.)" + "\b(?:(?:168)\.)" + "\b(?:(?:2)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" # 192.168.2.0/24
$Site3IPRange = "\b(?:(?:192)\.)" + "\b(?:(?:168)\.)" + "\b(?:(?:3)\.)" + "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))" # 192.168.3.0/24

########################
# Set the Location OUs #
########################

# Disabled OU
$DisabledDN = "OU=Disabled,DC=yourdomain,DC=com"

# OU Locations
$Site1DN = "OU=Site1,DC=yourdomain,DC=com"
$Site2DN = "OU=Site2,DC=yourdomain,DC=com"
$Site3DN = "OU=Site3,DC=yourdomain,DC=com"

###############
# The process #
###############

# Query Active Directory for Computers running Windows 7 (Any version) and move the objects to the correct OU based on IP
Get-ADComputer -Filter { OperatingSystem -like "Windows*" } -Properties PasswordLastSet | ForEach-Object {

	# Ignore Error Messages and continue on
	trap [System.Net.Sockets.SocketException] { continue; }

	# Set variables for Name and current OU
	$ComputerName = $_.Name
	$ComputerDN = $_.distinguishedName
	$ComputerPasswordLastSet = $_.PasswordLastSet
	$ComputerContainer = $ComputerDN.Replace( "CN=$ComputerName," , "")

	# If the computer is more than 90 days off the network, remove the computer object
	if ($ComputerPasswordLastSet -le $veryold) { 
		Remove-ADObject -Identity $ComputerDN
	}

	# Check to see if it is an "old" computer account and move it to the Disabled\Computers OU
	if ($ComputerPasswordLastSet -le $old) { 
		$DestinationDN = $DisabledDN
		Move-ADObject -Identity $ComputerDN -TargetPath $DestinationDN
	}

	# Query DNS for IP 
	# First we clear the previous IP. If the lookup fails it will retain the previous IP and incorrectly identify the subnet
	$IP = $NULL
	$IP = [System.Net.Dns]::GetHostAddresses("$ComputerName")

	# Use the $IPLocation to determine the computer's destination network location
	#
	#
	if ($IP -match $Site1IPRange) {
		$DestinationDN = $Site1DN
	}
	ElseIf ($IP -match $Site2IPRange) {
		$DestinationDN = $Site2DN
	}
	ElseIf ($IP -match $Site3IPRange) {
		$DestinationDN = $Site3DN
	}
	Else {
		# If the subnet does not match we should not move the computer so we do Nothing
		$DestinationDN = $ComputerContainer	
	}

	# Move the Computer object to the appropriate OU
	# If the IP is NULL we will trust it is an "old" or "very old" computer so we won't move it again
	if ($IP -ne $NULL) {
		Move-ADObject -Identity $ComputerDN -TargetPath $DestinationDN
	}
}