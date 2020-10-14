<# 
 
.SYNOPSIS
    Prepares Active Directory configuration for various purposes.

.DESCRIPTION

    AdSyncConfig.psm1 is a Windows PowerShell script module that provides functions that are
    used to prepare your Active Directory forest and domains for Azure AD Connect Sync
    features.
#>

#----------------------------------------------------------
#STATIC VARIABLES
#----------------------------------------------------------
# Well known SIDS
$selfSid = "S-1-5-10"
$enterpriseDomainControllersSid = "S-1-5-9"

<#.SYNOPSIS
        Tighten permissions on an AD object that is not otherwise included in any AD protected security group.
		A typical example is the AD Connect account (MSOL) created by AAD Connect automatically. This account
		has replicate permissions on all domains, however can be easily compromised as it is not protected.

    .DESCRIPTION
        The Set-ADSyncRestrictedPermissions Function will tighten permissions oo the 
		account provided. Tightening permissions involves the following steps:
		1. Disable inheritance on the specified object
		2. Remove all ACEs on the specific object, except ACEs specific to SELF. We want to keep
		   the default permissions intact when it comes to SELF.
		3. Assign these specific permissions:

				Type	Name										Access				Applies To
				=============================================================================================
				Allow	SYSTEM										Full Control		This object
				Allow	Enterprise Admins							Full Control		This object
				Allow	Domain Admins								Full Control		This object
				Allow	Administrators								Full Control		This object

				Allow	Enterprise Domain Controllers				List Contents
																	Read All Properties
																	Read Permissions	This object

				Allow	Authenticated Users							List Contents
																	Read All Properties
																	Read Permissions	This object

    .PARAMETER $ObjectDN
        The Active Directory account whose permissions need to be tightened.

	.PARAMETER $Credential
        The credential used to authenticate the client when talking to Active Directory. This is generally
		the Enterprise Admin credentials used to create the account whose permissions needs tightening.

    .EXAMPLE
       Set-ADSyncRestrictedPermissions -ObjectDN "CN=TestAccount1,CN=Users,DC=bvtadwbackdc,DC=com" -Credential $credential
	   $credential.UserName should be in domain\username format.
#>
function Set-ADSyncRestrictedPermissions
{
	[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="high")]
	param(
		[Parameter(Mandatory=$True)] [string] $ObjectDN,
		[Parameter(Mandatory=$True)] [System.Management.Automation.PSCredential] $Credential
	)

	if ($PSCmdlet.ShouldProcess($ObjectDN, "Set restricted permissions")) {
		try
		{
			$networkCredential = $Credential.GetNetworkCredential()
			$path = "LDAP://" + $networkCredential.Domain + "/" + $ObjectDN	

			$de = New-Object System.DirectoryServices.DirectoryEntry($path, $Credential.UserName, $networkCredential.Password)
			$selfName = Convert-SIDtoName $selfSid			
			
			# disable inheritance on the object and remove inherited DACLs
			$de.ObjectSecurity.SetAccessRuleProtection($true, $false);

			# remove all DACLs on the object except SELF
			$acl = $de.ObjectSecurity.GetAccessRules($true, $false, [System.Security.Principal.NTAccount])
			ForEach ($ace in $acl) {
				if ($ace.IdentityReference -ne $selfName) {
					$de.ObjectSecurity.RemoveAccessRule($ace) > $null
				}
			}

			# Add specific DACLs on the object
			# Add Full Control for SYSTEM
			$systemSid = New-Object System.Security.Principal.SecurityIdentifier([System.Security.Principal.WellKnownSidType]::LocalSystemSid, $null)
			$systemDacl = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($systemSid, [System.DirectoryServices.ActiveDirectoryRights]::GenericAll, [System.Security.AccessControl.AccessControlType]::Allow)
			$de.ObjectSecurity.AddAccessRule($systemDacl)

			# Add Full Control for Enterprise Admins
			$eaSid = Get-EnterpriseAdminsSid $Credential
			$eaDacl = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($eaSid, [System.DirectoryServices.ActiveDirectoryRights]::GenericAll, [System.Security.AccessControl.AccessControlType]::Allow)
			$de.ObjectSecurity.AddAccessRule($eaDacl)

			# Add Full Control for Domain Admins
			$daSid = Get-DomainAdminsSid $Credential
			$daDacl = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($daSid, [System.DirectoryServices.ActiveDirectoryRights]::GenericAll, [System.Security.AccessControl.AccessControlType]::Allow)
			$de.ObjectSecurity.AddAccessRule($daDacl)

			# Add Full Control for Administrators
			$adminSid = New-Object System.Security.Principal.SecurityIdentifier([System.Security.Principal.WellKnownSidType]::BuiltinAdministratorsSid, $null)
			$adminDacl = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($adminSid, [System.DirectoryServices.ActiveDirectoryRights]::GenericAll, [System.Security.AccessControl.AccessControlType]::Allow)
			$de.ObjectSecurity.AddAccessRule($adminDacl)

			# Add Generic Read for ENTERPRISE DOMAIN CONTROLLERS
			$edcSid = New-Object System.Security.Principal.SecurityIdentifier($enterpriseDomainControllersSid)
			$edcDacl = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($edcSid, [System.DirectoryServices.ActiveDirectoryRights]::GenericRead, [System.Security.AccessControl.AccessControlType]::Allow)
			$de.ObjectSecurity.AddAccessRule($edcDacl)

			# Add Generic Read for Authenticated Users
			$authenticatedUsersSid = New-Object System.Security.Principal.SecurityIdentifier([System.Security.Principal.WellKnownSidType]::AuthenticatedUserSid, $null)
			$authenticatedUsersDacl = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($authenticatedUsersSid, [System.DirectoryServices.ActiveDirectoryRights]::GenericRead, [System.Security.AccessControl.AccessControlType]::Allow)
			$de.ObjectSecurity.AddAccessRule($authenticatedUsersDacl)

			$de.CommitChanges()
			Write-Output "Setting Restricted permissions on $ObjectDN completed successfully."
		}
		catch [Exception]
		{
			Write-Error "Setting Restricted permissions on $ObjectDN failed. Exception Details: $_"
		}
		finally
		{
			if ($de.Value -ne $null)
			{
				$de.Dispose()
			}			
		}
	}
}

function Get-EnterpriseAdminsSid
{
	param(
		[Parameter(Mandatory=$True)] [System.Management.Automation.PSCredential] $Credential
	)

	$networkCredential = $Credential.GetNetworkCredential()
	$dc = New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext([System.DirectoryServices.ActiveDirectory.DirectoryContextType]::Domain, $networkCredential.Domain, $Credential.UserName, $networkCredential.Password)
	$domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetDomain($dc)		

	try
	{
		$de = $domain.Forest.RootDomain.GetDirectoryEntry()
		try
		{
			$rootDomainSidInBytes = $de.Properties["ObjectSID"].Value
			$domainSid = New-Object System.Security.Principal.SecurityIdentifier($rootDomainSidInBytes, 0)
			$eaSid = New-Object System.Security.Principal.SecurityIdentifier([System.Security.Principal.WellKnownSidType]::AccountEnterpriseAdminsSid, $domainSid)
			$eaSid
		}
		finally
		{
			if ($de.Value -ne $null)
			{
				$de.Dispose()
			}
		}
	}
	finally
	{
		if ($domain -ne $null)
		{
			$domain.Dispose()
		}
	}
}

function Get-DomainAdminsSid
{
	param(
		[Parameter(Mandatory=$True)] [System.Management.Automation.PSCredential] $Credential
	)

	$networkCredential = $Credential.GetNetworkCredential()
	$dc = New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext([System.DirectoryServices.ActiveDirectory.DirectoryContextType]::Domain, $networkCredential.Domain, $Credential.UserName, $networkCredential.Password)
	$domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetDomain($dc)

	try
	{
		$de = $domain.GetDirectoryEntry()
		try
		{
			$domainSidInBytes = $de.Properties["ObjectSID"].Value
			$domainSid = New-Object System.Security.Principal.SecurityIdentifier($domainSidInBytes, 0)
			$domainAdminsSid = New-Object System.Security.Principal.SecurityIdentifier([System.Security.Principal.WellKnownSidType]::AccountDomainAdminsSid, $domainSid)
			$domainAdminsSid
		}
		finally
		{
			if ($de.Value -ne $null)
			{
				$de.Dispose()
			}
		}
	}
	finally
	{
		if ($domain.Value -ne $null)
		{
			$domain.Dispose()
		}
	}
}

# Convert SIDs to readable names
function Convert-SIDtoName
{
	param(
		[Parameter(Mandatory=$True,Position=0)] [string] $sid
	)

	$ID = New-Object -TypeName System.Security.Principal.SecurityIdentifier -ArgumentList $sid
	$User = $ID.Translate([System.Security.Principal.NTAccount])
	$User.Value
}

Export-ModuleMember -Function Set-ADSyncRestrictedPermissions