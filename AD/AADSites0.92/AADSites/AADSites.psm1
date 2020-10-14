$ADver = $null

if ((get-module activedirectory) -ne $null){$adver = "MSAD"}
else{
	if ((Get-PSSnapin Quest.ActiveRoles.ADManagement -ea 0) -ne $null ){$adver = "QAD"}
	else{Write-Error "Either MS Active Directory pack or Quest AD tools are required.  Please load either module and try again";break}
}

switch ($ADver){
"MSAD"	{write-host "MSAD pack found and being used"}
"QAD"	{write-host "Quest AD pack found and being used"}
}

#region AD Sites
function New-AADSite {
<# 
.SYNOPSIS  
    Create a new AD site object
.DESCRIPTION  
    This function enables you to create a new AD Site. 
    You can supply any combination of sitelinks, description or location to add to the new site
.NOTES  
    Function Name   : new-AADSite
    Author          : Adam Stone
    Requires        : PowerShell V2 and Active Directory module
.LINK  
    http://adadmin.blogspot.com  
.EXAMPLE  
    create new AD site 
    new-AADSite -name mainsite1 -Sitelinks "sitelink 1" -location  "au/syd/office1" -description "Site description"
.EXAMPLE  
    create new AD site using positional parameters. Also, using multiple sitelinks.
    new-AADSite Sitename "sitelink 1,sitelink 2" "au/syd/office1" "Site description"
.EXAMPLE  
    create new AD site - only supply one value to set on creation
    new-AADSite -name Sitename -location "au/syd/office1" 
.PARAMETER name
	Mandatory - The name of the object you want to create.
	Position 0.
.PARAMETER Sitelinks
    Optional - The sitelinks of the site you want to add it to 
	Position 1.
.PARAMETER description
    Optional - The description of the site you want to set
	Position 2.
.PARAMETER location
    Optional - The location of the site you want to set
	Position 3.
#> 
   [CmdletBinding(ConfirmImpact="Low")]
   Param (
      [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,HelpMessage="Name of the site to be created. Name is the only supported identity for this version of the script.")]
      [alias("Indentity")]
      [String] $name,
      [Parameter(Mandatory=$false,Position=1,ValueFromPipeline=$false)]
      [string] $SiteLinks,
      [Parameter(Mandatory=$false,Position=2,ValueFromPipeline=$false)]
      [string] $Location = "",
      [Parameter(Mandatory=$false,Position=3,ValueFromPipeline=$false)]
      [string] $Description = ""
   )
   PROCESS {
        $newSiteName = $name
        if (-not $(Test-AADServicesObject -Identity $newSiteName -type Site)){
            $siteObjectCreated = $false
            try{
                $vars = @{}
                if (-not [String]::IsNullOrEmpty($location)){$vars.Add("location", $Location)}
                if (-not [String]::IsNullOrEmpty($Description)){$vars.Add("description", $Description)}
				switch ($ADver){
				"MSAD"	{
	                if ($vars.Count -gt 0){$newsite = New-ADObject -Name $newSiteName -Path "CN=Sites,$((Get-ADRootDSE).ConfigurationNamingContext)" -Type site -OtherAttributes $vars -PassThru}
	                else {$newsite = New-ADObject -Name $newSiteName -Path "CN=Sites,$((Get-ADRootDSE).ConfigurationNamingContext)" -Type site -PassThru}
					}
				"QAD"	{
					if ($vars.Count -gt 0){$newsite = New-QADObject -Name $newSiteName -ParentContainer "CN=Sites,$((Get-QADRootDSE).ConfigurationNamingContext)" -Type site -ObjectAttributes $vars}
					else {$newsite = New-QADObject -Name $newSiteName -ParentContainer "CN=Sites,$((Get-QADRootDSE).ConfigurationNamingContext)" -Type site}
					}
				}
				$siteObjectCreated = $true
				
				switch ($ADver){
				"MSAD"	{
	                New-ADObject -Name "NTDS Site Settings" -Path $($newsite.DistinguishedName) -Type nTDSSiteSettings
	                New-ADObject -Name "Servers" -Path $($newsite.DistinguishedName) -Type serversContainer
					}
				"QAD"	{
    	            $NTDSSS = New-QADObject -Name "NTDS Site Settings" -ParentContainer  $($newsite.DN) -Type nTDSSiteSettings
	                $NTDSServers = New-QADObject -Name "Servers" -ParentContainer $($newsite.DN) -Type serversContainer
					}
				}
                if (-not [String]::IsNullOrEmpty($SiteLinks)){
                    $SiteLinkArray = $SiteLinks.split(",")
                    foreach ($SiteLinkName in $SiteLinkArray){
                        $sitelinkOb = Get-AADServicesObject -identity $sitelinkname -type sitelink
                        if (-not [String]::IsNullOrEmpty($SiteLinkOb)){$addsitelink = Add-AADSiteToSitelink -identity $newSiteName -sitelink $sitelinkname}
                        else{Write-Warning "Sitelink - $SiteLinkName - not found in AD"}
                    }
                }
                return $newsite
            }catch{
                Write-Error $Error[0]
                if ($siteObjectCreated) {
					switch ($ADver){
					"MSAD"	{Remove-ADObject -Identity $newsite.DistinguishedName -Recursive -Confirm:$false}
					"QAD"	{Remove-QADObject -Identity $newsite.DN -DeleteTree -Force -Confirm:$false}
					}
				}
            }
        }else {Write-Error "Site name already exists"}
    }
}
function Get-AADsite {
<# 
.SYNOPSIS  
    Returns the AD site object that matches the name supplied
.DESCRIPTION  
    Returns the AD site object, if one exists, that matches the name given
    Returns $null if nothing found
.NOTES  
    Function Name   : Get-AADSite
    Author          : Adam Stone
    Requires        : PowerShell V2 and Active Directory module
.LINK  
    http://adadmin.blogspot.com  
.EXAMPLE  
    get AD site with name Sitename
    get-AADSite -identity Sitename
.EXAMPLE  
    return all AD sites
    get-AADSite
.PARAMETER identity
    Optional - The name of the object you want to return.
    Position 0. 
#> 
    [CmdletBinding(ConfirmImpact="Low")]
    Param (
       [Parameter(Mandatory=$false,Position=0,ValueFromPipeline=$true,HelpMessage="Identity of the AD site to return")]
       [string] $Identity = $null
    )
    try{return $(Get-AADServicesObject -type site -identity $identity)}
    catch{write-error $error[0];return $Null}
}
function Confirm-AADSite {
<# 
.SYNOPSIS  
    Confirms the values provided match the configured site settings
.DESCRIPTION  
    This function allows you to validate the settings of an AD Site. 
    You can supply any combination of sitelinks, description or location to check
    and the function will return true or false whether the values match or not.
.NOTES  
    Function Name   : confirm-AADSite
    Author          : Adam Stone
    Requires        : PowerShell V2 and Active Directory module
.LINK  
    http://adadmin.blogspot.com  
.EXAMPLE  
    confirm site mainsite values
    confirm-AADSite -Identity mainsite1 -Sitelinks "sitelink 1" -location  "au/syd/office1" -description "Site description"
.EXAMPLE  
    confirm site sitename values using positional parameters. Also, using multiple sitelinks.
    confirm-AADSite Sitename "sitelink 1,sitelink 2" "au/syd/office1" "Site description"
.EXAMPLE  
    confirm site sitename - only supply one value to check
    confirm-AADSite -identity Sitename  -location  "au/syd/office1" 
.PARAMETER identity
	Mandatory - The name of the object you want to confirm.
	Position 0.
.PARAMETER Sitelinks
    Optional - The sitelinks of the site you want to confirm
	Accepts 1 or more sitelinks, comma separated.
	Position 1.
.PARAMETER description
    Optional - The description of the site you want to confirm
	Position 2.
.PARAMETER location
    Optional - The location of the site you want to confirm
	Position 3.
#> 
    [CmdletBinding(ConfirmImpact="Low")]
    Param (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,HelpMessage="Identity required")]
        $Identity,
        [Parameter(Mandatory=$false,Position=1,ValueFromPipeline=$false)]
        [string] $SiteLinks,
        [Parameter(Mandatory=$false,Position=2,ValueFromPipeline=$False)]
        [string] $description = "",
        [Parameter(Mandatory=$false,Position=3,ValueFromPipeline=$False)]
        [string] $location = ""
    )
    try{
        $returnValue = $true
		switch ($ADver){
			"MSAD"	{
		        switch ($Identity){
		            {$_ -is [string]}{$site = Get-AADServicesObject -identity $Identity -type Site}
		            {$_ -is [Microsoft.ActiveDirectory.Management.ADObject]}{$site = $identity}
		        }
			}
			"QAD"	{$site = Get-AADServicesObject -identity $Identity -type Site}
		}	
        if ($site -ne $null){
            if (-not [String]::IsNullOrEmpty($SiteLinks)){
                $SiteLinkArray = $SiteLinks.split(",")
                foreach ($SiteLinkName in $SiteLinkArray){
                    $sitelinkOb = Get-AADServicesObject -identity $sitelinkname -type sitelink
                    if (-not [String]::IsNullOrEmpty($SiteLinkOb)){
                        $Sitelinksitelist = $sitelinkob.sitelist | % {$_.split(",")[0].replace("CN=","")}
                        if (-not $Sitelinksitelist -contains $Identity){Write-Warning "Sitelink Validation Failed: site missing from Sitelink $sitelinkname";$returnValue = $false}
                    }else{Write-Warning "Sitelink - $SiteLinkName - not found";$returnValue = $false}
                }
            }
            if (-not $($Location -eq $Site.location) -and -not [String]::IsNullOrEmpty($location)){Write-warning "Location validation failed.";$returnValue = $false}
            if (-not $($Description -eq $Site.description) -and -not [String]::IsNullOrEmpty($Description)){Write-warning "Description validation failed.";$returnValue = $false}

            return $returnValue
        }else {write-error "Site not found";return $false}
    }
    catch{write-error $error[0];return $false}
}
function Set-AADSite {
<# 
.SYNOPSIS  
    Sets the values of an AD site object
.DESCRIPTION  
    This function allows you to set the values of an AD Site. 
    You can supply any combination of sitelinks, description or location to set
.NOTES  
    Function Name   : set-AADSite
    Author          : Adam Stone
    Requires        : PowerShell V2 and Active Directory module
.LINK  
    http://adadmin.blogspot.com  
.EXAMPLE  
    update values for site mainsite
    set-AADSite -Identity mainsite1 -Sitelinks "sitelink 1" -location  "au/syd/office1" -description "Site description"
.EXAMPLE  
    update values for site sitename - using positional parameters. Also, using multiple sitelinks.
    set-AADSite Sitename "sitelink 1,sitelink 2" "au/syd/office1" "Site description"
.EXAMPLE  
    update values for site sitename - only supply one value to set
    set-AADSite -identity Sitename -location "au/syd/office1" 
.PARAMETER identity
	Mandatory - The name of the object you want to set.
	Position 0.
.PARAMETER Sitelinks
    Optional - The sitelinks of the site you want to set
	Position 1.
.PARAMETER description
    Optional - The description of the site you want to set
	Position 2.
.PARAMETER location
    Optional - The location of the site you want to set
	Position 3.
#> 
    [CmdletBinding(ConfirmImpact="Low")]
    Param (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,HelpMessage="Identity required")]
        $Identity,
        [Parameter(Mandatory=$false,Position=1,ValueFromPipeline=$false)]
        [string] $SiteLinks,
        [Parameter(Mandatory=$false,Position=2,ValueFromPipeline=$False)]
        [string] $description = "",
        [Parameter(Mandatory=$false,Position=3,ValueFromPipeline=$False)]
        [string] $location = ""
    )
    try{
		switch ($ADver){
			"MSAD"	{
		        switch ($Identity){
		            {$_ -is [string]}{$site = Get-AADServicesObject -identity $Identity -type Site}
		            {$_ -is [Microsoft.ActiveDirectory.Management.ADObject]}{$site = $identity}
		        }
			}
			"QAD"	{$site = Get-AADServicesObject -identity $Identity -type Site}
		}		
        if ($site -ne $null){
            $vars = @{}
            if (-not [String]::IsNullOrEmpty($SiteLinks)){
                $SiteLinkArray = $SiteLinks.split(",")
                foreach ($SiteLinkName in $SiteLinkArray){
                    $sitelinkOb = Get-AADServicesObject -identity $sitelinkname -type sitelink
                    if (-not [String]::IsNullOrEmpty($SiteLinkOb)){
                        $Sitelinksitelist = $sitelinkob.sitelist | % {$_.split(",")[0].replace("CN=","")}
                        if ($Sitelinksitelist -notcontains $Identity){$return = Add-AADSiteToSitelink -identity $($_.inputobject) -sitelink $sitelinkname}
                    }else{Write-Warning "Sitelink - $SiteLinkName - not found in AD"}
                }
            }
            if (-not $($Location -eq $Site.location) -and -not [String]::IsNullOrEmpty($location)){$vars.Add("location", $Location)}
            if (-not $($Description -eq $Site.description) -and -not [String]::IsNullOrEmpty($Description)){$vars.Add("description", $Description)}
            if ($vars.Count -gt 0){
				switch ($ADver){
				"MSAD"	{set-ADObject -identity $site -replace $vars}
				"QAD"	{$returnsitelink = Set-QADObject -Identity $site -ObjectAttributes $vars}
				}
			}
            return $(Get-AADServicesObject -identity $identity -type site)
        }else {write-error "Site not found in AD";return $null}
    }
    catch{write-error $error[0];return $null}
}
function Remove-AADsite {
<# 
.SYNOPSIS  
    Removes the AD site object that matches the name supplied
.DESCRIPTION  
    Removes the AD site object, if one exists, that matches the name given
	If there are configured domain controllers in the site, the site will not
	be removed.
	If there are server objects in the site (that are not DC's), the command 
	requires -force:$true option to remove the site
	If there are subnets associated with the site, the command requires
	-force:$true option to remove the site.
	Returns True if the the site has been removed, False if not. 
.NOTES  
    Function Name   : remove-AADSite
    Author          : Adam Stone
    Requires        : PowerShell V2 and Active Directory module
.LINK  
    http://adadmin.blogspot.com  
.EXAMPLE  
    remove site Sitename
    remove-AADSite -identity Sitename
.EXAMPLE  
    remove a site without being prompted to confirm
    remove-AADSite -identity Sitename -confirm:$false
.EXAMPLE  
    force the removal of a site with associated subnets 
	or non DC servers
    remove-AADSite -identity Sitename -force:$true
.PARAMETER identity
    Mandatory - The name of the object you want to remove.
    Position 0. 
.PARAMETER force
    Optional - Set to true if you want to ignore warnings and remove the site
    Position 1.
.PARAMETER confirm
    Optional - Set to false if you want to remove the site without being
	prompted
    Position 2.
#> 
    [CmdletBinding(ConfirmImpact="Low")]
    Param (
       [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,HelpMessage="Identity of the AD site to remove")]
       [string] $Identity,
       [Parameter(Mandatory=$false,Position=1,ValueFromPipeline=$true,HelpMessage="Force delete when subnets and servers are attached to the site")]
       [boolean] $force = $false,
       [Parameter(Mandatory=$false,Position=2,ValueFromPipeline=$true,HelpMessage="confirm delete - set to false for no prompt")]
       [boolean] $confirm = $true
    )
    try{
        $siteToRemove = Get-AADServicesObject -identity $identity -type site
        $returnValue = $false
        if ($sitetoRemove -ne $null){
			switch ($ADver){
			"MSAD"	{$childnTDSDSAObjects = Get-ADObject -Filter {ObjectClass -eq "nTDSDSA"} -SearchBase "CN=Servers,$($siteToRemove.DistinguishedName)"}
			"QAD"	{$childnTDSDSAObjects = Get-QADObject -ldapfilter '(ObjectClass = "nTDSDSA")' -Searchroot "CN=Servers,$($siteToRemove.DistinguishedName)"}
			}
            if ($childnTDSDSAObjects -ne $null){Write-Warning "Site has associated Domain Controller(s). Move the DC's to another site before removing the site";$returnValue = $false}
            else{
				switch ($ADver){
				"MSAD"	{$childServerObjects = Get-ADObject -Filter {ObjectClass -eq "server"} -SearchBase "CN=Servers,$($siteToRemove.DistinguishedName)"}
				"QAD"	{$childServerObjects = Get-QADObject -ldapfilter '(ObjectClass = "server")' -SearchRoot "CN=Servers,$($siteToRemove.DistinguishedName)"}
				}
                if ($force){
					switch ($ADver){
					"MSAD"	{Remove-ADObject -Identity $siteToRemove.DistinguishedName -Recursive -Confirm:$confirm;$returnValue = $true}
					"QAD"	{Remove-QADObject -Identity $siteToRemove.DistinguishedName -DeleteTree -force -Confirm:$confirm;$returnValue = $true}
					}
				}else{
                    if ($childserverobjects -ne $null){Write-Warning "Site has  associated server(s).  Review server objects in site before removing.  Use `"-force `$true`" option to override";$returnValue = $false}
                    else{
						switch ($ADver){
	                    "MSAD"	{
							if ($siteToRemove.siteobjectbl[0] -eq $null){Remove-ADObject -Identity $siteToRemove.DistinguishedName -Recursive -Confirm:$confirm;$returnValue = $true}
							else{Write-Warning "Site has associated subnets. Either move the subnets or use `"-force:`$true`" option";$returnValue = $false}
							}
						"QAD"	{
							if ($siteToRemove.siteobjectbl -eq $null){Remove-QADObject -Identity $siteToRemove.DistinguishedName -DeleteTree -force -Confirm:$confirm;$returnValue = $true}
							else{Write-Warning "Site has associated subnets. Either move the subnets or use `"-force:`$true`" option";$returnValue = $false}
							}
						}
                    }
                }
            }
        }else{Write-Warning "Site name not found in AD";$returnValue = $false}
        return $retunvalue
    }catch{Write-Error $error[0];return $false}
}
#EndRegion
#region AD Site links
function New-AADSiteLink {
<# 
.SYNOPSIS  
    Creates a new AD sitelink object
.DESCRIPTION  
    This function enables you to create a new AD Sitelink. 
    You can supply any combination of sites, cost, frequency or description to set
.NOTES  
    Function Name   : new-AADSitelink
    Author          : Adam Stone
    Requires        : PowerShell V2 and Active Directory module
.LINK  
    http://adadmin.blogspot.com  
.EXAMPLE  
    create new sitelink sitelinkname
    new-AADSitelink -name sitelinkname -Sites "testsite1,testsite2" -cost 50 -frequency 30 -description "Main sitelink"
.EXAMPLE  
    create new sitelink sitelinkname using positional parameters.
    new-AADSitelink sitelinkname "testsite1,testsite2" 50 30  "Main sitelink"
.EXAMPLE  
    create new sitelink sitelinkname -  only supply two values to set
    new-AADSitelink -name sitelinkname -cost 50 -frequency 30
.PARAMETER name
	Mandatory - The name of the object you want to create.
	Position 0.
.PARAMETER Sites
    Optional - The sites you want to add to the site link.
	Accepts 1 or more sites, comma separated.
	Position 1.
.PARAMETER cost
    Optional - The cost of the sitelink you want to set
	Position 2.
.PARAMETER frequency
    Optional - The frequency of replication the sitelink (in minutes) you want to set
	Position 3.
.PARAMETER description
    Optional - The description of the sitelink you want to set
	Position 4.
#> 
   [CmdletBinding(ConfirmImpact="Low")]
   Param (
      [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,HelpMessage="Name of the sitelink to be created. Name is the only supported identity for this version of the script.")]
      [alias("Indentity")]
      [String] $name,
      [Parameter(Mandatory=$true,Position=1,ValueFromPipeline=$false,HelpMessage="Add the names of 1 or more sites to add to the link, comma separated.")]
      [string] $Sites,
      [Parameter(Mandatory=$false,Position=2,ValueFromPipeline=$false,HelpMessage="Cost value needs to be an integer - default 100")]
      [int] $cost = "100",
      [Parameter(Mandatory=$false,Position=3,ValueFromPipeline=$false,HelpMessage="Frequency value needs to be an integer (in Minutes) - default 180")]
      [int] $frequency = "180",
      [Parameter(Mandatory=$false,Position=4,ValueFromPipeline=$false)]
      [string] $description = ""
   )
   PROCESS {
        $newSiteLinkName = $name
        $sitesadded = $false
        if (-not $(Test-AADServicesObject -Identity $newSiteLinkName -type Sitelink)){
            $siteLinkObjectCreated = $false
            try{
                if (-not [String]::IsNullOrEmpty($Sites)){
                    $sitesToAdd = @()
                    $vars = @{}
                    $SiteArray = $Sites.split(",")
                    foreach ($SiteName in $SiteArray){
                        if (-not $(Test-AADServicesObject -Identity $SiteName -type Site)) {Write-warning "Site $sitename not found in AD"}
                        else{$sitesToAdd += ,$(get-AADServicesObject -Identity $SiteName -type Site ).DistinguishedName;$sitesadded = $true}
                    }
                    if ($sitesadded){$vars.Add("sitelist", $sitesToAdd)}
                    $vars.Add("cost", $Cost)
                    $vars.Add("replInterval", $frequency)
                    if (-not [String]::IsNullOrEmpty($Description)){$vars.Add("description", $Description)}
					switch ($ADver){
					"MSAD"	{
	                    if ($vars.Count -gt 0){$newsitelink = New-ADObject -Name $newSiteLinkName -Path "CN=IP,CN=Inter-Site Transports,CN=Sites,$((Get-ADRootDSE).ConfigurationNamingContext)" -Type sitelink -OtherAttributes $vars -PassThru}
	                    else{$newsitelink = New-ADObject -Name $newSiteLinkName -Path "CN=IP,CN=Inter-Site Transports,CN=Sites,$((Get-ADRootDSE).ConfigurationNamingContext)" -Type sitelink -PassThru}
						}
					"QAD"	{
						if ($vars.Count -gt 0){$newsitelink = New-QADObject -Name $newSiteLinkName -ParentContainer "CN=IP,CN=Inter-Site Transports,CN=Sites,$((Get-QADRootDSE).ConfigurationNamingContext)" -Type sitelink -ObjectAttributes $vars}
						else {$newsitelink = New-QADObject -Name $newSiteLinkName -ParentContainer "CN=IP,CN=Inter-Site Transports,CN=Sites,$((Get-QADRootDSE).ConfigurationNamingContext)" -Type sitelink}
						}
					}
                    $siteObjectCreated = $true
                    return $newsitelink
                }else{Write-Error "Site name required"}
            }catch{
				Write-Error $error[0]
				if ($sitelinkObjectCreated) {
					switch ($ADver){
					"MSAD"	{Remove-ADObject -Identity $newsitelink.DistinguishedName -Recursive -Confirm:$false}
					"QAD"	{Remove-QADObject -Identity $newsitelink.DN -DeleteTree -Force -Confirm:$false}
					}
				}
			}
        }else{Write-Error "Site link name already exists"}
    }
}
function Get-AADsitelink {
<# 
.SYNOPSIS  
    Returns the AD sitelink object that matches the name supplied
.DESCRIPTION  
    Returns the AD site object, if one exists, that matches the name given
    Returns $null if nothing found
.NOTES  
    Function Name   : Get-AADSite
    Author          : Adam Stone
    Requires        : PowerShell V2 and Active Directory module
.LINK  
    http://adadmin.blogspot.com  
.EXAMPLE  
    get site link sitelinkname
    get-AADSitelink -identity SiteLinkname
.EXAMPLE  
 	return all sitelinks
    get-AADSitelink
.PARAMETER identity
	Optional - The name of the object you want to return.
	Position 0.
#> 
    [CmdletBinding(ConfirmImpact="Low")]
    Param (
       [Parameter(Mandatory=$false,Position=0,ValueFromPipeline=$true,HelpMessage="Identity of the AD sitelink to return")]
       [string] $Identity
    )
    try{return $(Get-AADServicesObject -type sitelink -identity $identity)}
    catch{write-error $error[0];return $Null}
}
function Confirm-AADSitelink {
<# 
.SYNOPSIS  
    Confirms the values provided match the configured sitelink settings
.DESCRIPTION  
    This function allows you to validate the settings of an AD Sitelink. 
    You can supply any combination of sites, cost, frequency or description to check
    and the function will return true or false whether the values match or not.
.NOTES  
    Function Name   : confirm-AADSitelink
    Author          : Adam Stone
    Requires        : PowerShell V2 and Active Directory module
.LINK  
    http://adadmin.blogspot.com  
.EXAMPLE  
    confirm the settings of site link sitelinkname
    confirm-AADSitelink -Identity sitelinkname -Sites "testsite1,testsite2" -cost 50 -frequency 30 -description "Main sitelink"
.EXAMPLE  
    confirm the settings of site link sitelinkname using positional parameters.
    confirm-AADSitelink sitelinkname "testsite1,testsite2" 50 30  "Main sitelink"
.EXAMPLE  
    confirm the settings of site link sitelinkname - only supply two values to check
    confirm-AADSitelink -identity sitelinkname -cost 50 -frequency 30
.PARAMETER identity
	Mandatory - The name of the object you want to confirm.
	Position 0.
.PARAMETER Sites
    Optional - The sites of the sitelink you want to confirm.
	Accepts 1 or more sites, comma separated.
	Position 1.
.PARAMETER cost
    Optional - The cost of the sitelink you want to confirm
	Position 2.
.PARAMETER frequency
    Optional - The frequency of replication the sitelink (in minutes) you want to confirm
	Position 3.
.PARAMETER description
    Optional - The description of the sitelink you want to confirm
	Position 4.
#> 
    [CmdletBinding(ConfirmImpact="Low")]
    Param (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,HelpMessage="Identity required")]
        $Identity,
        [Parameter(Mandatory=$false,Position=1,ValueFromPipeline=$false)]
        [string] $Sites = "",
        [Parameter(Mandatory=$false,Position=2,ValueFromPipeline=$false)]
        $cost = $null,
        [Parameter(Mandatory=$false,Position=3,ValueFromPipeline=$false)]
        $frequency = $null,
        [Parameter(Mandatory=$false,Position=4,ValueFromPipeline=$false)]
        [string] $description = ""
    )
    try{
        $returnValue = $true
		switch ($ADver){
			"MSAD"	{
		        switch ($Identity){
		            {$_ -is [string]}{$sitelink = Get-AADServicesObject -identity $Identity -type Sitelink}
		            {$_ -is [Microsoft.ActiveDirectory.Management.ADObject]}{$sitelink = $identity}
		        }	
			}
			"QAD"	{$sitelink = Get-AADServicesObject -identity $Identity -type Sitelink}
		}
        if ($sitelink -ne $null){
			if (-not [String]::IsNullOrEmpty($Sites)){
				$SiteArray = $Sites.split(",")
	            $Sitelinksitelist = $sitelink.sitelist | % {$_.split(",")[0].replace("CN=","")}
				if ([String]::IsNullOrEmpty($Sitelinksitelist) -and [String]::IsNullOrEmpty($SiteArray)){}
				if ([String]::IsNullOrEmpty($Sitelinksitelist) -and -not [String]::IsNullOrEmpty($SiteArray)){Write-Warning "Site list Validation Failed: No sites configued in Sitelink";$returnValue = $false}
				if (-not [String]::IsNullOrEmpty($Sitelinksitelist) -and -not  [String]::IsNullOrEmpty($SiteArray)){
		            switch (Compare-Object -ReferenceObject $SiteArray -DifferenceObject $Sitelinksitelist){
		                {$_.SideIndicator -eq "=>"} {Write-Warning "Site list Validation Failed: extra site found - $($_.inputobject)";$returnValue = $false}
		                {$_.SideIndicator -eq "<="} {Write-Warning "Site list Validation Failed: site missing - $($_.inputobject)";$returnValue = $false}
		            }			
				}			
			}
            if (-not $($cost -eq $Sitelink.cost) -and -not [String]::IsNullOrEmpty($cost)){Write-warning "cost validation failed.";$returnValue = $false}
            if (-not $($frequency -eq $Sitelink.replInterval) -and -not [String]::IsNullOrEmpty($frequency)){Write-warning "frequency validation failed.";$returnValue = $false}
            if (-not $($Description -eq $Sitelink.description) -and -not [String]::IsNullOrEmpty($Description)){Write-warning "Description validation failed.";$returnValue = $false}
            return $returnValue
        }else {write-error "Sitelink not found";return $false}
    }
    catch{write-error $error[0];return $false}
}
function Set-AADSitelink {
<# 
.SYNOPSIS  
    Sets the values of an AD sitelink object
.DESCRIPTION  
    This function allows you to set the values of an AD Sitelink. 
    You can supply any combination of sites, cost, frequency or description to set
.NOTES  
    Function Name   : set-AADSitelink
    Author          : Adam Stone
    Requires        : PowerShell V2 and Active Directory module
.LINK  
    http://adadmin.blogspot.com  
.EXAMPLE  
    update the values of site link sitelinkname
    set-AADSitelink -Identity sitelinkname -Sites "testsite1,testsite2" -cost 50 -frequency 30 -description "Main sitelink"
.EXAMPLE  
    update the values of site link sitelinkname - using positional parameters.
    set-AADSitelink sitelinkname "testsite1,testsite2" 50 30  "Main sitelink"
.EXAMPLE  
    update the values of site link sitelinkname - only supply two values to set
    set-AADSitelink -identity sitelinkname -cost 50 -frequency 30
.PARAMETER identity
	Mandatory - The name of the object you want to change.
	Position 0.
.PARAMETER Sites
    Optional - The sites of the sitelink you want to set.
	Accepts 1 or more sites, comma separated.
	Position 1.
.PARAMETER cost
    Optional - The cost of the sitelink you want to set
	Position 2.
.PARAMETER frequency
    Optional - The frequency of replication the sitelink (in minutes) you want to set
	Position 3.
.PARAMETER description
    Optional - The description of the sitelink you want to set
	Position 4.
#> 
    [CmdletBinding(ConfirmImpact="Low")]
    Param (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,HelpMessage="Identity required")]
        $Identity,
        [Parameter(Mandatory=$false,Position=1,ValueFromPipeline=$false)]
        [string] $Sites,
        [Parameter(Mandatory=$false,Position=2,ValueFromPipeline=$false,HelpMessage="Cost value needs to be an integer")]
        $cost = $null,
        [Parameter(Mandatory=$false,Position=3,ValueFromPipeline=$false,HelpMessage="Frequency value needs to be an integer (in minutes)")]
        $frequency = $null,
        [Parameter(Mandatory=$false,Position=4,ValueFromPipeline=$false)]
        [string] $description = ""
    )
    try{
		switch ($ADver){
			"MSAD"	{
		        switch ($Identity){
		            {$_ -is [string]}{$sitelink = Get-AADServicesObject -identity $Identity -type Sitelink}
		            {$_ -is [Microsoft.ActiveDirectory.Management.ADObject]}{$sitelink = $identity}
		        }	
			}
			"QAD"	{$sitelink = Get-AADServicesObject -identity $Identity -type Sitelink}
		}
        if ($sitelink -ne $null){
            $vars = @{}
			if (-not [String]::IsNullOrEmpty($Sites)){
	            $SiteArray = $Sites.split(",")
	            $Sitelinksitelist = $sitelink.sitelist | % {$_.split(",")[0].replace("CN=","")}
	            switch (Compare-Object -ReferenceObject $SiteArray -DifferenceObject $Sitelinksitelist){
	                {$_.SideIndicator -eq "<="} {$return = add-AADSiteToSitelink -identity $($_.inputobject) -sitelink $identity}
					{$_.SideIndicator -eq "=>"} {$return = Remove-AADSiteFromSitelink -identity $($_.inputobject) -sitelink $identity}
	            }
			}
            if (-not $($cost -eq $Sitelink.cost) -and -not [String]::IsNullOrEmpty($cost) -and $cost -is [int]){$vars.Add("cost", $Cost)}
            if (-not $($frequency -eq $Sitelink.replInterval) -and -not [String]::IsNullOrEmpty($frequency) -and $frequency -is [int]){$vars.Add("replInterval", $frequency)}
            if (-not $($Description -eq $Sitelink.description) -and -not [String]::IsNullOrEmpty($Description)){$vars.Add("description", $Description)}
            if ($vars.Count -gt 0){
				switch ($ADver){
				"MSAD"	{set-ADObject -identity $sitelink -replace $vars}
				"QAD"	{$returnsitelink = Set-QADObject -Identity $sitelink -ObjectAttributes $vars}
				}
			}
            return $(Get-AADServicesObject -identity $identity -type sitelink)
        }else {write-error "Sitelink not found in AD";return $null}
    }
    catch{write-error $error[0];return $null}
}
function Remove-AADsitelink {
<# 
.SYNOPSIS  
    Removes the AD sitelink object that matches the name supplied
.DESCRIPTION  
    Removes the AD sitelink object, if one exists, that matches the name given
	If there are sites configured as part of the sitelink, the command 
	requires -force:$true option to remove the site
	Returns True if the the site has been removed, False if not. 
.NOTES  
    Function Name   : remove-AADSitelink
    Author          : Adam Stone
    Requires        : PowerShell V2 and Active Directory module
.LINK  
    http://adadmin.blogspot.com  
.EXAMPLE  
    remove site link sitelinkname
    remove-AADSitelink -identity Sitelinkname
.EXAMPLE  
    remove a sitelink without being prompted to confirm
    remove-AADSitelink -identity Sitelinkname -confirm:$false
.EXAMPLE  
    force the removal of a sitelink with associated sites
    remove-AADSitelink -identity Sitelinkname -force:$true
.PARAMETER identity
    Mandatory - The name of the object you want to remove.
    Position 0. 
.PARAMETER force
    Optional - Set to true if you want to ignore warnings and remove the 
	sitelink
    Position 1.
.PARAMETER confirm
    Optional - Set to false if you want to remove the sitelink without being
	prompted
    Position 2.
#> 
    [CmdletBinding(ConfirmImpact="Low")]
    Param (
       [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,HelpMessage="Identity of the AD sitelink to remove")]
       [string] $Identity,
       [Parameter(Mandatory=$false,Position=1,ValueFromPipeline=$true,HelpMessage="Force delete when sites are part of the sitelink")]
       [boolean] $force = $false,
       [Parameter(Mandatory=$false,Position=2,ValueFromPipeline=$true,HelpMessage="confirm delete - set to false for no prompt")]
       [boolean] $confirm = $true
    )
    try{
        $sitelinkToRemove = Get-AADServicesObject -identity $identity -type sitelink
        $returnValue = $false
        if ($sitelinktoRemove -ne $null){
            if ($force){
				switch ($ADver){
				"MSAD"	{Remove-ADObject -Identity $sitelinkToRemove.DistinguishedName -Recursive -Confirm:$confirm;$returnValue = $true}
				"QAD"	{Remove-QADObject -Identity $sitelinkToRemove.DistinguishedName -DeleteTree -force -Confirm:$confirm;$returnValue = $true}
				}
			}
            else{       
                if ($sitelinkToRemove.sitelist[0] -eq $null){
					switch ($ADver){
					"MSAD"	{Remove-ADObject -Identity $sitelinkToRemove.DistinguishedName -Recursive -Confirm:$confirm;$returnValue = $true}
					"QAD"	{Remove-QADObject -Identity $sitelinkToRemove.DistinguishedName -DeleteTree -Force -Confirm:$confirm;$returnValue = $true}
					}
				}else{Write-Warning "Sitelink has associated sites. Either remove the sites or use `"-force:`$true`" option";$returnValue = $false}
            }
        }else{Write-Warning "Sitelink name not found in AD";$returnValue = $false}
        return $retunvalue
    }catch{Write-Error $error[0];return $false}
}
#EndRegion
#region AD Subnets
function New-AADSubnet {
<# 
.SYNOPSIS  
    Creates a new AD subnet object
.DESCRIPTION  
    This function enables you to create a new AD Subnet. 
    You can supply any combination of site, description or location to set
.NOTES  
    Function Name   : new-AADSubnet
    Author          : Adam Stone
    Requires        : PowerShell V2 and Active Directory module
.LINK  
    http://adadmin.blogspot.com  
.EXAMPLE  
    create new subnet 192.168.30.0/24
    new-AADSubnet -name 192.168.30.0/24 -Site "testsite1" -location "au/syd/ho1/lvl1" -description "Head office level 1 subnet"
.EXAMPLE  
    create new subnet 192.168.30.0/24 using positional parameters.
    new-AADSubnet 192.168.30.0/24 "testsite1" "au/syd/ho1/lvl1" "Head office level 1 subnet"
.EXAMPLE  
    create new subnet 192.168.30.0/24 - only supply one value to set on create
    new-AADSubnet -name 192.168.30.0/24 -location "au/syd/ho1/lvl1"
.PARAMETER name
	Mandatory - The name of the object you want to create.
	Position 0.
.PARAMETER Site
    Mandatory - The site that the subnet belongs to.
	Position 1.
.PARAMETER description
    Optional - The description of the subnet you want to set
	Position 2.
.PARAMETER location
    Optional - The location of the subnet you want to set
	Position 3.
#> 
   [CmdletBinding(ConfirmImpact="Low")]
   Param (
      [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,HelpMessage="Name of the subnet to be created. This should be a combination of IP Address followed by / and Prefix length. IPv4 example: 157.54.208.0/20  IPv6 example: 3FFE:FFFF:0:C000::/64 . NOTE: If the prefix length is not specified then this cmdlet will auto-generate the prefix length based on the number of trailing zero bits. For example: If supplied Prefix is 157.54.208.0 then the subnet created is 157.54.208.0/20. Another example: If supplied Prefix is 3FFE:FFFF:0:C000:: then the subnet created is 3FFE:FFFF:0:C000::/34")]
      [alias("Indentity")]
      [String] $name,
      [Parameter(Mandatory=$True,Position=1,ValueFromPipeline=$false,HelpMessage="Site to which the subnet will be applied.")]
      [string] $Site,
      [Parameter(Mandatory=$false,Position=2,ValueFromPipeline=$false,HelpMessage="Description")]
      [String] $Description = "",
      [Parameter(Mandatory=$false,Position=3,ValueFromPipeline=$false,HelpMessage="Location")]
      [String] $Location = ""
   )
   PROCESS {
        $newSubnetName = $name
        $subnetObjectCreated = $false
        if ($newSubnetName.Contains("/")) {
            $subnetIPAddressStr,$prefixLengthStr = $newSubnetName.Split("/")
            $subnetIPAddress = [System.Net.IPAddress]::Parse($subnetIPAddressStr)
            $specifiedPrefixLength = [int]::Parse($prefixLengthStr)
            $ipAddressPrefixLength = Get-IPAddressPrefixLength $subnetIPAddress
            if ($ipAddressPrefixLength -gt $specifiedPrefixLength) {write-error "The subnet prefix length you specified is incorrect.";break}
        }else{write-error "invalid subnet name format.  Required format - 192.168.1.0/24";break}
        if (-not $(Test-AADServicesObject -Identity $newSubnetName -type subnet)) {
            try{
                $vars = @{}
                if (-not [String]::IsNullOrEmpty($site)){
                    $siteOb = Get-AADServicesObject -identity $site -type site
                    if ($siteob -eq $null){Write-warning "Site not found in AD"}
                    else{$vars.Add("siteobject", $($siteob.distinguishedname))}
                }
                if (-not [String]::IsNullOrEmpty($location)){$vars.Add("location", $Location)}
                if (-not [String]::IsNullOrEmpty($Description)){$vars.Add("description", $Description)}
				switch ($ADver){
				"MSAD"	{
	                if ($vars.Count -gt 0){$newsubnet = New-ADObject -Name $newSubnetName -Path "CN=Subnets,CN=Sites,$((Get-ADRootDSE).ConfigurationNamingContext)" -Type subnet -OtherAttributes $vars -PassThru}
	                else{$newsubnet = New-ADObject -Name $newSubnetName -Path "CN=Subnets,CN=Sites,$((Get-ADRootDSE).ConfigurationNamingContext)" -Type subnet -PassThru}					}
				"QAD"	{
					if ($vars.Count -gt 0){$newsite = New-QADObject -Name $newSubnetName -ParentContainer "CN=Subnets,CN=Sites,$((Get-QADRootDSE).ConfigurationNamingContext)" -Type subnet -ObjectAttributes $vars}
					else {$newsite = New-QADObject -Name $newSubnetName -ParentContainer "CN=Subnets,CN=Sites,$((Get-QADRootDSE).ConfigurationNamingContext)" -Type subnet}
					}
				}
                $subnetObjectCreated = $true
                return $newsubnet
            }catch{
				write-error $error[0]
				if ($subnetObjectCreated){
					switch ($ADver){
					"MSAD"	{Remove-ADObject -Identity $newsubnet.DistinguishedName -Confirm:$false}
					"QAD"	{Remove-QADObject -Identity $newsubnet.DN -Confirm:$false}
					}
				}
			}
        }else{Write-Error "Subnet already exists"}
    }
}
function Get-AADsubnet {
<# 
.SYNOPSIS  
    Returns the AD subnet object that matches the name supplied
.DESCRIPTION  
    Returns the AD subnet object, if one exists, that matches the name given
    Returns $null if nothing found
.NOTES  
    Function Name   : Get-AADsubnet
    Author          : Adam Stone
    Requires        : PowerShell V2 and Active Directory module
.LINK  
    http://adadmin.blogspot.com  
.EXAMPLE  
    get AD subnet 10.0.1.0/24
    get-AADSubnet -identity 10.0.1.0/24
.EXAMPLE  
    get all AD subnets
    get-AADSubnet
.PARAMETER identity
    Optional - The name of the object you want to return.
    Position 0.
#> 
    [CmdletBinding(ConfirmImpact="Low")]
    Param (
       [Parameter(Mandatory=$false,Position=0,ValueFromPipeline=$true,HelpMessage="Identity of the AD subnet to return")]
       [string] $Identity
    )
    try{return $(Get-AADServicesObject -type subnet -identity $identity)}
    catch{write-error $error[0];return $Null}
}
function Confirm-AADSubnet {
<# 
.SYNOPSIS  
    Confirms the values provided match the configured subnet settings
.DESCRIPTION  
    This function allows you to validate the settings of an AD Subnet. 
    You can supply any combination of site, description or location to check
    and the function will return true or false whether the values match or not.
.NOTES  
    Function Name   : confirm-AADSubnet
    Author          : Adam Stone
    Requires        : PowerShell V2 and Active Directory module
.LINK  
    http://adadmin.blogspot.com  
.EXAMPLE  
    confirm the values of subnet 192.168.30.0/24
    confirm-AADSubnet -Identity 192.168.30.0/24 -Site "testsite1" -location "au/syd/ho1/lvl1" -description "Head office level 1 subnet"
.EXAMPLE  
    confirm the values of subnet 192.168.30.0/24 using positional parameters.
    confirm-AADSubnet 192.168.30.0/24 "testsite1" "au/syd/ho1/lvl1" "Head office level 1 subnet"
.EXAMPLE  
    confirm the values of subnet 192.168.30.0/24 - only supply one value to confirm
    confirm-AADSubnet -Identity 192.168.30.0/24 -location "au/syd/ho1/lvl1"
.PARAMETER identity
	Mandatory - The name of the object you want to confirm.
	Position 0.
.PARAMETER Site
    Optional - The site that the subnet belongs to.
	Position 1.
.PARAMETER description
    Optional - The description of the subnet you want to confirm
	Position 2.
.PARAMETER location
    Optional - The location of the subnet you want to confirm
	Position 3.
#> 
    [CmdletBinding(ConfirmImpact="Low")]
    Param (
       [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,HelpMessage="Identity required")]
       $Identity,
       [Parameter(Mandatory=$false,Position=1,ValueFromPipeline=$False)]
       [string] $description = "",
       [Parameter(Mandatory=$false,Position=2,ValueFromPipeline=$False)]
       [string] $location = "",
       [Parameter(Mandatory=$false,Position=3,ValueFromPipeline=$False)]
       [string] $site = ""
    )
    try{
        $returnValue = $true
		switch ($ADver){
			"MSAD"	{
		        switch ($Identity){
		            {$_ -is [string]}{$subnet = Get-AADServicesObject -identity $Identity -type Subnet}
		            {$_ -is [Microsoft.ActiveDirectory.Management.ADObject]}{$subnet = $identity}
		        }		
			}
			"QAD"	{$subnet = Get-AADServicesObject -identity $identity -type subnet}
		}
        if ($subnet -ne $null){
            if (-not [String]::IsNullOrEmpty($site)){
                $siteOb = Get-AADServicesObject -identity $site -type site
                if ($siteob -eq $null){$siteCheck = $true;$returnValue = $false;Write-warning "Site name not found in AD"}
                else{$siteCheck = $($siteob.distinguishedname -eq $subnet.siteobject)}
            }else{$siteCheck = $true}
            
            if (-not $($Location -eq $Subnet.location) -and -not [String]::IsNullOrEmpty($location)){
                Write-warning "Location validation failed."
                $returnValue = $false
            }
            if (-not $($Description -eq $Subnet.description) -and -not [String]::IsNullOrEmpty($Description)){
                Write-warning "Description validation failed."
                $returnValue = $false
            }
            if (-not $siteCheck -and -not [String]::IsNullOrEmpty($siteob)){
                Write-warning "Site validation failed."
                $returnValue = $false
            }
            return $returnValue
        }else {write-error "Subnet not found in AD";return $false}
    }
    catch{write-error $error[0];return $false}
}
function Set-AADSubnet {
<# 
.SYNOPSIS  
    Sets the values of an AD subnet object
.DESCRIPTION  
    This function allows you to set the values of an AD Subnet. 
    You can supply any combination of site, description or location to set
.NOTES  
    Function Name   : set-AADSubnet
    Author          : Adam Stone
    Requires        : PowerShell V2 and Active Directory module
.LINK  
    http://adadmin.blogspot.com  
.EXAMPLE  
    update the values of subnet 192.168.30.0/24
    set-AADSubnet -Identity 192.168.30.0/24 -Site "testsite1" -location "au/syd/ho1/lvl1" -description "Head office level 1 subnet"
.EXAMPLE  
    update the values of subnet 192.168.30.0/24 using positional parameters.
    set-AADSubnet 192.168.30.0/24 "testsite1" "au/syd/ho1/lvl1" "Head office level 1 subnet"
.EXAMPLE  
    update the values of subnet 192.168.30.0/24 - only supply one value to change
    set-AADSubnet -Identity 192.168.30.0/24 -location "au/syd/ho1/lvl1"
.PARAMETER identity
	Mandatory - The name of the object you want to set.
	Position 0.
.PARAMETER Site
    Optional - The site that the subnet belongs to.
	Position 1.
.PARAMETER description
    Optional - The description of the subnet you want to set
	Position 2.
.PARAMETER location
    Optional - The location of the subnet you want to set
	Position 3.
#> 
    [CmdletBinding(ConfirmImpact="Low")]
    Param (
       [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,HelpMessage="Identity required")]
       $Identity,
       [Parameter(Mandatory=$false,Position=1,ValueFromPipeline=$False)]
       [string] $description = "",
       [Parameter(Mandatory=$false,Position=2,ValueFromPipeline=$False)]
       [string] $location = "",
       [Parameter(Mandatory=$false,Position=3,ValueFromPipeline=$False)]
       [string] $site = ""
    )
    try{
		switch ($ADver){
			"MSAD"	{
		        switch ($Identity){
		            {$_ -is [string]}{$subnet = Get-AADServicesObject -identity $Identity -type Subnet}
		            {$_ -is [Microsoft.ActiveDirectory.Management.ADObject]}{$subnet = $identity}
		        }		
			}
			"QAD"	{$subnet = Get-AADServicesObject -identity $identity -type subnet}
		}
        if ($subnet -ne $null){
            $vars = @{}
            if (-not [String]::IsNullOrEmpty($site)){
                $siteOb = Get-AADServicesObject -identity $site -type site
                if ($siteob -eq $null){$siteCheck = $true;Write-Warning "Site Not found in AD"}
                else{$siteCheck = $($siteob.distinguishedname -eq $subnet.siteobject)}
            }else{$siteCheck = $true}
            if (-not $($Location -eq $Subnet.location) -and -not [String]::IsNullOrEmpty($location)){$vars.Add("location", $Location)}
            if (-not $($Description -eq $Subnet.description) -and -not [String]::IsNullOrEmpty($Description)){$vars.Add("description", $Description)}
            if (-not $siteCheck -and -not [String]::IsNullOrEmpty($siteob)){$vars.Add("siteobject", $siteob.distinguishedname)}
            if ($vars.Count -gt 0){
				switch ($ADver){
				"MSAD"	{set-ADObject -identity $subnet -replace $vars}
				"QAD"	{$returnsubnet = Set-QADObject -Identity $subnet -ObjectAttributes $vars}
				}
			}
            return $(Get-AADServicesObject -identity $identity -type subnet)
        }else {write-error "Subnet not found in AD";return $null}
    }
    catch{write-error $error[0];return $null}
}
function Remove-AADsubnet {
<# 
.SYNOPSIS  
    Removes the AD subnet object that matches the name supplied
.DESCRIPTION  
    Removes the AD subnet object, if one exists, that matches the name given
	Returns True if the the site has been removed, False if not. 
.NOTES  
    Function Name   : remove-AADSubnet
    Author          : Adam Stone
    Requires        : PowerShell V2 and Active Directory module
.LINK  
    http://adadmin.blogspot.com  
.EXAMPLE  
    remove subnet 192.168.30.0/24
    remove-AADSubnet -identity 192.168.30.0/24
.EXAMPLE  
    remove a Subnet without being prompted to confirm
    remove-AADSubnet -identity 192.168.30.0/24 -confirm:$false
.PARAMETER identity
    Mandatory - The name of the object you want to remove.
    Position 0. 
.PARAMETER confirm
    Optional - Set to false if you want to remove the subnet without being
	prompted
    Position 1.
#> 
    [CmdletBinding(ConfirmImpact="Low")]
    Param (
       [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,HelpMessage="Identity of the AD subnet to remove")]
       [string] $Identity,
       [Parameter(Mandatory=$false,Position=1,ValueFromPipeline=$true,HelpMessage="confirm delete - set to false for no prompt")]
       [boolean] $confirm = $true
    )
    try{
		switch ($ADver){
			"MSAD"	{
		        switch ($Identity){
		            {$_ -is [string]}{$subnetToRemove = Get-AADServicesObject -identity $identity -type subnet}
		            {$_ -is [Microsoft.ActiveDirectory.Management.ADObject]}{$subnettoremove = $identity}
		        }			
			}
			"QAD"	{$subnetToRemove = Get-AADServicesObject -identity $identity -type subnet}
		}	
	
        
        $returnValue = $false
        if ($subnettoRemove -ne $null){
			switch ($ADver){
			"MSAD"	{Remove-ADObject -Identity $subnetToRemove.DistinguishedName -Recursive -Confirm:$confirm;$returnValue = $true}
			"QAD"	{Remove-QADObject -Identity $subnetToRemove.DistinguishedName -DeleteTree -Force -Confirm:$confirm;$returnValue = $true}
			}
		}
        else{Write-Warning "Subnet name not found in AD";$returnValue = $false}
        return $retunvalue
    }catch{Write-Error $error[0];return $false}
}
#EndRegion
#region other functions
function Test-AADServicesObject {
<# 
.SYNOPSIS  
    Checks to see whether an AD object exists with the name and type supplied
.DESCRIPTION  
    Checks to see whether an AD object exists with the name and type supplied.  
    returns true if exists and false if not.
.NOTES  
    Function Name   : Test-AADServicesObject
    Author          : Adam Stone
    Requires        : PowerShell V2 and Active Directory module
.LINK  
    http://adadmin.blogspot.com  
.EXAMPLE  
    check to see if a site with name sitename exists
    Test-AADServicesObject -identity Sitename -type Site
.EXAMPLE  
    check to see if a sitelink with name sitelinkname exists
    Test-AADServicesObject -identity Sitelinkname -type Sitelink
.EXAMPLE  
    check to see if a subnet with name 10.0.1.0/24 exists
    Test-AADServicesObject -identity 10.0.1.0/24 -type subnet
.PARAMETER identity
    Mandatory - The name of the object you want to check.
    Position 0. 
.PARAMETER Type  
    Mandatory - The type of the object to check.
    Accepts site, subnet or sitelink.
    Position 1. 
#> 
    [CmdletBinding(ConfirmImpact="Low")]
    Param (
       [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,HelpMessage="Identity of the AD object to verify if exists or not.")]
       [string] $Identity,
       [Parameter(Mandatory=$true,Position=1,ValueFromPipeline=$False,HelpMessage="Allowed values for type are Site, Subnet or Sitelink")]
       [validateset("site","subnet","sitelink")]
       [string] $Type
    )
	switch ($ADver){
	"MSAD"	{
	    try{return $($(Get-ADObject -LDAPFilter "(&(objectClass=$type)(name=$identity))" -SearchBase $((Get-ADRootDSE).ConfigurationNamingContext)) -ne $null)}
	    catch{write-error $error[0];return $false}		
		}
	"QAD"	{
	    try{return $($(Get-QADObject -LdapFilter "(&(objectClass=$type)(name=$identity))" -SearchRoot $((Get-QADRootDSE).ConfigurationNamingContext)) -ne $null)}
	    catch{write-error $error[0];return $false}
		}
	}
}
function Get-AADServicesObject {
<# 
.SYNOPSIS  
    Returns an AD object that matches the name and type supplied
.DESCRIPTION  
    Returns an AD object, if one exists, that matches the name and type.
    Returns $null if nothing found
.NOTES  
    Function Name   : Get-AADServicesObject
    Author          : Adam Stone
    Requires        : PowerShell V2 and Active Directory module
.LINK  
    http://adadmin.blogspot.com  
.EXAMPLE  
    
    get-AADServicesObject -identity Sitename -type Site
.EXAMPLE  
    
    get-AADServicesObject -identity Sitelinkname -type Sitelink
.EXAMPLE  
    
    get-AADServicesObject -identity 10.0.1.0/24 -type subnet
.PARAMETER identity
    Mandatory - The name of the object you want to return.
    Position 0. 
.PARAMETER Type  
    Mandatory - The type of the object to check.
    Accepts site, subnet or sitelink.
    Position 1. 
#> 
    [CmdletBinding(ConfirmImpact="Low")]
    Param (
       [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$False,HelpMessage="Allowed values for type are Site, Subnet or Sitelink")]
       [validateset("site","subnet","sitelink")]
	   [string] $Type,
       [Parameter(Mandatory=$false,Position=1,ValueFromPipeline=$true,HelpMessage="Identity of the AD object to return")]
       [string] $Identity = $null
    )
    try{
		switch ($ADver){
		"MSAD"	{
			if ([string]::IsNullOrEmpty($Identity)){return $(Get-ADObject -LDAPFilter "(&(objectClass=$type))" -SearchBase $((Get-ADRootDSE).ConfigurationNamingContext) -Properties *)}
			else{return $(Get-ADObject -LDAPFilter "(&(objectClass=$type)(name=$identity))" -SearchBase $((Get-ADRootDSE).ConfigurationNamingContext) -Properties *)}
			}
		"QAD"	{
			if ([string]::IsNullOrEmpty($Identity)){return $(Get-QADObject -LdapFilter "(&(objectClass=$type))" -SearchRoot $((Get-QADRootDSE).ConfigurationNamingContext) -IncludeAllProperties)}
			else{return $(Get-QADObject -LdapFilter "(&(objectClass=$type)(name=$identity))" -SearchRoot $((Get-QADRootDSE).ConfigurationNamingContext) -IncludeAllProperties)}
			}
		}
	}catch{write-error $error[0];return $Null}
}
function Add-AADSiteToSitelink {
<# 
.SYNOPSIS  
    Add an AD site to a sitelink
.DESCRIPTION  
    Add an AD site to a sitelink  
    returns true if successful and false if not.
.NOTES  
    Function Name   : Add-AADSiteToSitelink
    Author          : Adam Stone
    Requires        : PowerShell V2 and Active Directory module
.LINK  
    http://adadmin.blogspot.com  
.EXAMPLE  
    
    Add-AADSiteToSitelink -identity Sitename -sitelink Sitelinkname
.EXAMPLE  
     - using positional parameters
    Add-AADSiteToSitelink Sitename Sitelinkname
.PARAMETER identity
    Mandatory - The name of the site you want to add.
    Position 0. 
.PARAMETER sitelink  
    Mandatory - The name of the sitelink to add the site to
    Position 1. 
#> 
    [CmdletBinding(ConfirmImpact="Low")]
    Param (
       [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,HelpMessage="Site Identity required")]
       $Identity,
       [Parameter(Mandatory=$true,Position=1,ValueFromPipeline=$False,HelpMessage="Sitelink Identity required")]
       [string] $sitelink
    )
    try{
		switch ($ADver){
			"MSAD"	{
		        switch ($Identity){
		            {$_ -is [string]}{$site = Get-AADServicesObject -identity $Identity -type Site}
		            {$_ -is [Microsoft.ActiveDirectory.Management.ADObject]}{$site = $identity}
		        }	
			}
			"QAD"	{$site = Get-AADServicesObject -identity $Identity -type Site}
		}
        $sitelinkOb = Get-AADServicesObject -identity $sitelink -type sitelink
        if ($sitelinkob -eq $null){
            Write-error "Sitelink not found in AD"
            return $false
        }else{
            if ($($sitelinkob.sitelist -notcontains $site.distinguishedname)){
				switch ($ADver){
					"MSAD"	{
						$numberOfSitesInSiteLink = $siteLinkOb.siteList.add($($site.distinguishedname))
						Set-ADObject -Instance $siteLinkOb	
					}
					"QAD"	{
						$ADSIsitelink = [ADSI]"$($sitelinkOb.path)" 
						$numberOfSitesInSiteLink = $ADSIsitelink.sitelist.psbase.add($($site.distinguishedname))
						$ADSIsitelink.commitchanges()
					}
				}
                return $true
            }
        }
    }catch{write-error $error[0];return $false}
}
function Remove-AADSiteFromSitelink {
<# 
.SYNOPSIS  
    Remove an AD site from a sitelink
.DESCRIPTION  
    Remove an AD site from a sitelink
    returns true if successful and false if not.
.NOTES  
    Function Name   : Remove-AADSiteFromSitelink
    Author          : Adam Stone
    Requires        : PowerShell V2 and Active Directory module
.LINK  
    http://adadmin.blogspot.com  
.EXAMPLE  
    
    Remove-AADSiteFromSitelink -identity Sitename -sitelink Sitelinkname
.EXAMPLE  
     - using positional parameters
    Remove-AADSiteFromSitelink Sitename Sitelinkname
.PARAMETER identity
    Mandatory - The name of the site you want to remove.
    Position 0. 
.PARAMETER sitelink  
    Mandatory - The name of the sitelink to remove the site from
    Position 1. 
#> 
    [CmdletBinding(ConfirmImpact="Low")]
    Param (
       [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,HelpMessage="Site Identity required")]
       $Identity,
       [Parameter(Mandatory=$true,Position=1,ValueFromPipeline=$False,HelpMessage="Sitelink Identity required")]
       [string] $sitelink
    )
    try{
		switch ($ADver){
			"MSAD"	{
		        switch ($Identity){
		            {$_ -is [string]}{$site = Get-AADServicesObject -identity $Identity -type Site}
		            {$_ -is [Microsoft.ActiveDirectory.Management.ADObject]}{$site = $identity}
		        }	
			}
			"QAD"	{$site = Get-AADServicesObject -identity $Identity -type Site}
		}		
        $sitelinkOb = Get-AADServicesObject -identity $sitelink -type sitelink
        if ($sitelinkob -eq $null){
            Write-error "Sitelink not found in AD"
            return $false
        }else{
            if ($($sitelinkob.sitelist -contains $site.distinguishedname)){
				switch ($ADver){
					"MSAD"	{
		                if ($siteLinkOb.siteList.count -gt 1){
							$numberOfSitesInSiteLink = $siteLinkOb.siteList.remove($($site.distinguishedname))
							Set-ADObject -Instance $siteLinkOb	
						}else{Write-Warning "At least one site is required to be part of a site link.  Add another site before removing this one"}
					}
					"QAD"	{
						$ADSIsitelink = [ADSI]"$($sitelinkOb.path)" 
						if ($ADSIsitelink.siteList.psbase.count -gt 1){
							$numberOfSitesInSiteLink = $ADSIsitelink.sitelist.psbase.remove($($site.distinguishedname))
							$ADSIsitelink.commitchanges()
						}else{Write-Warning "At least one site is required to be part of a site link.  Add another site before removing this one"}
					}
				}
				return $true
            }
        }
    }catch{write-error $error[0];return $false}
}
function Move-AADSubnetToSite {
<# 
.SYNOPSIS  
    Move a subnet to a different site
.DESCRIPTION  
    Move a subnet to a different site
    returns true if successful and false if not.
.NOTES  
    Function Name   : move-AADSubnetToSite
    Author          : Adam Stone
    Requires        : PowerShell V2 and Active Directory module
.LINK  
    http://adadmin.blogspot.com  
.EXAMPLE  
    
    move-AADSubnetToSite -identity 192.168.1.0/24 -site Sitename
.EXAMPLE  
     - using positional parameters
    move-AADSubnetToSite 192.168.1.0/24 Sitename
.PARAMETER identity
    Mandatory - The name of the subnet you want to move.
    Position 0. 
.PARAMETER site  
    Mandatory - The name of the site to move the subnet to
    Position 1. 
#> 
    [CmdletBinding(ConfirmImpact="Low")]
    Param (
       [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,HelpMessage="Subnet Identity required")]
       $Identity,
       [Parameter(Mandatory=$true,Position=1,ValueFromPipeline=$False,HelpMessage="Site Identity required")]
       [string] $site
    )
    try{
        $returnValue = $true
		switch ($ADver){
			"MSAD"	{
		        switch ($Identity){
		            {$_ -is [string]}{$subnet = Get-AADServicesObject -identity $Identity -type Subnet}
		            {$_ -is [Microsoft.ActiveDirectory.Management.ADObject]}{$subnet = $identity}
		        }			
			}
			"QAD"	{$subnet = Get-AADServicesObject -identity $Identity -type Subnet}
		}		

        $vars = @{}
        $siteOb = Get-AADServicesObject -identity $site -type site
        if ($siteob -eq $null){
            Write-error "Site not found in AD"
            return $false
        }else{
            if (-not $($siteob.distinguishedname -eq $subnet.siteobject)){
				switch ($ADver){
					"MSAD"	{
		                $vars.Add("siteobject", $siteob.distinguishedname)
		                set-ADObject -identity $subnet -replace $vars					
					}
					"QAD"	{
						$ADSIsubnet = [ADSI]"$($subnet.path)" 
						$ADSIsubnet.siteObject = $($siteob.distinguishedname)
						$ADSIsubnet.CommitChanges()		
					}
				}
				return $true
            }
        }
    }
    catch{write-error $error[0];return $false}
}
function Get-NumberOfTrailingZeroes {
<# 
.SYNOPSIS  
    Internal utility function
.DESCRIPTION  
    This function returns the number of trailing zeroes in the input byte
.NOTES  
    Function Name   : Get-NumberOfTrailingZeroes
    Author          : Swaminathan Pattabiraman
    Requires        : Powershell V2
.LINK  
    http://blogs.msdn.com/ 
#> 
    Param ([byte] $x)
    $numOfTrailingZeroes = 0;
    if ($x -eq 0) {return 8}
    if ($x % 2 -eq 0) {
       $numOfTrailingZeroes ++;
       $numOfTrailingZeroes +=  Get-NumberOfTrailingZeroes($x/2);
    }
    return $numOfTrailingZeroes
}
function Get-IPAddressPrefixLength {
<# 
.SYNOPSIS  
    Internal utility function
.DESCRIPTION  
    This function returns the number of non-zero bits in an ip-address
.NOTES  
    Function Name   : Get-IPAddressPrefixLength
    Author          : Swaminathan Pattabiraman
    Requires        : Powershell V2
.LINK  
    http://blogs.msdn.com/
#> 
    Param ([System.Net.IPAddress] $ipAddress)
    $byteArray = $ipAddress.GetAddressBytes()
    $numOfTrailingZeroes = 0;
    for ($i = $byteArray.Length - 1; $i -ge 0; $i--) {
        $numOfZeroesInByte = Get-NumberOfTrailingZeroes($byteArray[$i]);
        if ($numOfZeroesInByte -eq 0) {break;}
        $numOfTrailingZeroes += $numOfZeroesInByte;
    }
    (($byteArray.Length * 8) - $numOfTrailingZeroes)
}
#EndRegion













