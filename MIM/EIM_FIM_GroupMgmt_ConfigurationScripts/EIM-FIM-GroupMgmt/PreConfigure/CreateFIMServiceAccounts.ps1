#########################################################
#
# Name: CreateFIMServiceAccounts.ps1
# Version: 1.0
# Date: 05/31/2011
# Comment: Script to create default FIM 2010
#          accounts for both service and app accounts.
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
$targetOU = "OU=Service Accounts,OU=Administration,DC=contoso,DC=com"

# Find the current domain info
$domdns = (Get-ADDomain).dnsroot # for UPN generation

# Specify the folder and CSV file to use
$impfile = "C:\EIM-FIM-GroupMgmt\PreConfigure\FIMServiceAccounts.csv"

# Check if the target OU is valid
$validOU = Test-XADObject $targetOU
If (!$validOU)
{
 write-host "Error: Specified OU for new users does not exist - exiting...."
 exit
} 

# Set the password for all new users
$password = read-host "Enter password" -assecurestring

# Parse the import file and action each line
$users = Import-CSV $impFile
foreach ($user in $users)
{
$samname = $user.samaccountname
$dplname = $samname
$desc = $user.description
$upname = "$samname" + "@" +"$domdns"
New-ADUser –Name $dplname –SamAccountName $samname –DisplayName $dplname -Description $desc -userprincipalname $upname `
-Path $targetou –Enabled $true –ChangePasswordAtLogon $False -PasswordNeverExpires $true `
-AccountPassword $password
}