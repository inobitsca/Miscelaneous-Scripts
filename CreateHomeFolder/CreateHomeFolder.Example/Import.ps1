param (
    $Username,
	$Password,
	$OperationType
    )


#Needs reference to .NET assembly used in the script.
Add-Type -AssemblyName System.DirectoryServices.Protocols

$CookieFile = "D:\HomeFolder\cookie.bin"

#Getting Cookie from file
If (Test-Path $CookieFile –PathType leaf) { 
    [byte[]] $Cookie = Get-Content -Encoding byte –Path $CookieFile
} else { 
    $Cookie = $null
}

#region User
$Properties = @("objectGuid","sAMAccountName","homeDirectory", "isDeleted")

#Running as FIM MA Account
$Credentials = New-Object System.Net.NetworkCredential($username,$password)
$RootDSE = [ADSI]"LDAP://RootDSE"
$LDAPDirectory = New-Object System.DirectoryServices.Protocols.LdapDirectoryIdentifier($RootDSE.dnsHostName)
$LDAPConnection = New-Object System.DirectoryServices.Protocols.LDAPConnection($LDAPDirectory, $Credentials) 
$Request = New-Object System.DirectoryServices.Protocols.SearchRequest($RootDSE.defaultNamingContext, "(&(objectClass=user)(eduPersonAffiliation=*))", "Subtree", $Properties) 

#Defining the object type returned from searches for performance reasons.
[System.DirectoryServices.Protocols.SearchResultEntry]$entry = $null


if ($OperationType -eq "Full")
{
    $Cookie = $null
}
else
{
    # delta run and we should use the cookie we already found
}


$DirSyncRC = New-Object System.DirectoryServices.Protocols.DirSyncRequestControl($Cookie, [System.DirectoryServices.Protocols.DirectorySynchronizationOptions]::IncrementalValues, [System.Int32]::MaxValue) 
$Request.Controls.Add($DirSyncRC) | Out-Null
    
$MoreData = $true
$Guids = @()

while ($MoreData) {
    $Response = $LDAPConnection.SendRequest($Request)

    ForEach($entry in $Response.Entries){
    #Check if this GUID already been handled to avoid adding duplicate objects
    If($Guids -contains ([GUID] $entry.Attributes["objectguid"][0]).ToString()){continue}

    # we always add objectGuid and objectClass to all objects
    $obj = @{}
    $obj.Add("objectGuid", ([GUID] $entry.Attributes["objectguid"][0]).ToString())
    $obj.Add("objectClass", "user")
    if ( $entry.distinguishedName.Contains("CN=Deleted Objects"))
	{
		# this is a deleted object, so we return a changeType of 'delete'; default changeType is 'Add'
		$obj.Add("changeType", "Delete")
	}
	else
	{
		# we need to get the directory entry to get the additional attributes since
		# these are not available if we are running a delta import (DirSync) and
		# they haven't changed. Using just the SearchResult would only get us
		# the changed attributes on delta imports and we need more, oooh, so much more
        # You need to work with Searcher object in case you want to deal with msExchRecipientTypeDetails. It is of iADSLargeInteger type that cannot be read using DirectoryEntry
		$DirEntry = New-Object System.DirectoryServices.DirectoryEntry "LDAP://$($entry.distinguishedName)"
        
		# setting the values
        # add the attributes defined in the schema
        $obj.Add("accountName",$DirEntry.Properties["sAMAccountName"][0])
        $obj.Add("homeFolderPath",$DirEntry.Properties["homeDirectory"][0])
        #TODO: Not sure how to add or manage homeFolderQuota yet
        }
        #Add Guid to list of processed guids to avoid duplication
        $Guids += ,([GUID] $entry.Attributes["objectguid"][0]).ToString()
        #Return the object to the MA
	    $obj
    }
    
    ForEach ($Control in $Response.Controls) { 
        If ($Control.GetType().Name -eq "DirSyncResponseControl") { 
            $Cookie = $Control.Cookie 
            $MoreData = $Control.MoreData 
            } 
        } 
    $DirSyncRC.Cookie = $Cookie 
    }

#Saving cookie file
Set-Content -Value $Cookie -Encoding byte –Path $CookieFile
$global:RunStepCustomData = [System.Convert]::ToBase64String($Cookie)
#endregion