#########################################################
#
# Name: CreateFIMGroups.ps1
# Version: 1.0
# Date: 05/31/2011
# Comment: Script to create default FIM 2010
#          groups in preparation for install.
#
#########################################################

# Function to test existence of AD object
function Test-XADObject() {
   [CmdletBinding(ConfirmImpact="Low")]
   Param (
      [Parameter(Mandatory=$true,
                 Position=0,
                 ValueFromPipeline=$true,
                 HelpMessage="Identity of the AD object to verify if exists or not."
                )]
      [Object] $Identity
   )
   trap [Exception] {
      return $false
   }
   $auxObject = Get-ADObject -Identity $Identity
   return $true
}

# Import the Active Directory Powershell Module
Import-Module ActiveDirectory -ErrorAction SilentlyContinue

# Specify the target OU for new users
$targetOU = "OU=Administrative Groups,OU=Administration,DC=contoso,DC=com"

# Find the current domain info
$domdns = (Get-ADDomain).dnsroot # for UPN generation

# Specify the folder and CSV file to use
$impfile = "C:\EIM-FIM-GroupMgmt\PreConfigure\FIMGroups.csv"

# Check if the target OU is valid
$validOU = Test-XADObject $targetOU
If (!$validOU)
{
 write-host "Error: Specified OU for new groups does not exist - exiting...."
 exit
} 

# Parse the import file and action each line
$groups = Import-CSV $impFile
foreach ($group in $groups)
{
$samname = $group.name
$dplname = $samname
$desc = $group.description

New-ADGroup –Name $dplname -GroupScope Global -Description $desc -DisplayName $dplname -GroupCategory Security -SamAccountName $samname -Path $targetou
}