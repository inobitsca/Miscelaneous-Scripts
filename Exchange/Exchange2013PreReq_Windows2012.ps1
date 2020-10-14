##################################################################
## Configure Exchange 2013 prerequisites on Windows 2012 Server ##
##################################################################
##                  (c) 2012 - Benoit HAMET                     ##
## http://blog.hametbenoit.info/Lists/Posts/Post.aspx?ID=431    ##
## 25/10/2012 - v1.0                                            ##
##################################################################


## Self Elevating Permission
## Get the ID and security principal of the current user account
 $myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
 $myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)


 ## Get the security principal for the Administrator role
 $adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator


 ## Check to see if we are currently running "as Administrator"
 if ($myWindowsPrincipal.IsInRole($adminRole))
    {
    ## We are running "as Administrator" - so change the title and background color to indicate this
    $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
    $Host.UI.RawUI.BackgroundColor = "DarkBlue"
    clear-host
    }
 else
    {
    ## We are not running "as Administrator" - so relaunch as administrator
    
    ## Create a new process object that starts PowerShell
    $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
    
    ## Specify the current script path and name as a parameter
    $newProcess.Arguments = $myInvocation.MyCommand.Definition;
    
    ## Indicate that the process should be elevated
    $newProcess.Verb = "runas";
    
    ## Start the new process
    [System.Diagnostics.Process]::Start($newProcess);
    
    ## Exit from the current, unelevated, process
    exit
    }


Import-Module BitsTransfer
Import-Module ServerManager


## Prompt for the destination path
$DestFolder = Read-Host -Prompt "- Enter the destination path for downloaded files"


## Check that the path entered is valid
If (Test-Path "$DestFolder" -Verbose)
{
	## If destination path is valid, create folder if it doesn't already exist
	New-Item -ItemType Directory $DestFolder -ErrorAction SilentlyContinue
}
Else
{
	Write-Warning " - Destination path appears to be invalid."
	## Pause
	Write-Host " - Please check the path, and try running the script again."
	Write-Host "- Press any key to exit..."
	$null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	break
}

"##################################################################
## Configure Exchange 2013 prerequisites on Windows 2012 Server ##
##  1 - Install Exchange 2013 CAS                               ##
##  2 - Install Exchange 2013 Mailbox                           ##
##  3 - Install Exchange 2013 Multirole                         ##
##################################################################"
$InstallMode = Read-Host


##################################################################
## Configure Exchange 2013 prerequisites on Windows 2012 Server ##
##               Exchange Front End Server (CAS)                ##
##################################################################
If ($InstallMode -Eq 1 -Or $InstallMode -Eq 3)
{
## Download prerequisites files for Exchange 2013 Back End
## Hard-coded URL below used saved to get destination filename $DestFileName)
## Note: These URLs are subject to change at Microsoft's discretion - check the permalink next to each if you have trouble downloading.
$UrlList = ("http://download.microsoft.com/download/2/C/4/2C47A5C1-A1F3-4843-B9FE-84C0032C61EC/UcmaRuntimeSetup.exe" #Unified Communications Managed API 4.0 Runtime
			)
}



##################################################################
## Configure Exchange 2013 prerequisites on Windows 2012 Server ##
##             Exchange Back End Server (mailboxes)             ##
##################################################################
If ($InstallMode -Eq 2 -Or $InstallMode -Eq 3)
{
## Download prerequisites files for Exchange 2013 Back End
## Hard-coded URL below used saved to get destination filename $DestFileName)
## Note: These URLs are subject to change at Microsoft's discretion - check the permalink next to each if you have trouble downloading.
$UrlList = ("http://download.microsoft.com/download/0/A/2/0A28BBFA-CBFA-4C03-A739-30CCA5E21659/FilterPack64bit.exe", #Microsoft Office 2010 Filter Packs
            "http://download.microsoft.com/download/A/A/3/AA345161-18B8-45AE-8DC8-DA6387264CB9/filterpack2010sp1-kb2460041-x64-fullfile-en-us.exe", #Service Pack 1 for Microsoft Office Filter Pack 2010
			"http://download.microsoft.com/download/2/C/4/2C47A5C1-A1F3-4843-B9FE-84C0032C61EC/UcmaRuntimeSetup.exe" #Unified Communications Managed API 4.0 Runtime
			)

}


## Installing prerequisite files
ForEach ($Url in $UrlList)
{
	## Get the file name based on the portion of the URL after the last slash
	$DestFileName = $Url.Split('/')[-1]
	Try
	{
		## Check if destination file already exists
		If (!(Test-Path "$DestFolder\$DestFileName"))
		{
			## Begin download
			Start-BitsTransfer -Source $Url -Destination $DestFolder\$DestFileName -DisplayName "Downloading `'$DestFileName`' to $DestFolder" -Priority High -Description "From $Url..." -ErrorVariable err
			If ($err) {Throw ""}
		}
		Else
		{
			Write-Host " - File $DestFileName already exists, skipping..."
		}
	}
	Catch
	{
		Write-Warning " - An error occurred downloading `'$DestFileName`'"
		break
	}
}


If ($InstallMode -Eq 1 -Or $InstallMode -Eq 2 -Or $InstallMode -Eq 3)
{
## Unified Communications Managed API 4.0 Runtime
Write-Host "Installing Unified Communications Managed API 4.0 Runtime"
$InstalCmd ="$DestFolder\UcmaRunTimeSetup.exe"
&$InstalCmd "/quiet /norestart" | Out-Null
}


If ($InstallMode -Eq 2 -Or $InstallMode -Eq 3)
{
## Install Microsoft Office 2010 Filter Packs
$InstalCmd ="$DestFolder\filterpack64bit.exe"
&$InstalCmd "/quiet" | Out-Null
Write-Host "Installing Microsoft Office 2010 Filter Packs"


## Install Service Pack 1 for Microsoft Office Filter Pack 2010
Write-Host "Installing Service Pack 1 for Microsoft Office Filter Pack 2010"
$InstalCmd ="$DestFolder\filterpack2010sp1-kb2460041-x64-fullfile-en-us.exe"
&$InstalCmd "/quiet" | Out-Null
}


## Activating Windows Server Roles & Features
Write-Host "Installing Windows Server Roles & Features requiered for Exchange 2013 Front End"
Install-WindowsFeature AS-HTTP-Activation, Desktop-Experience, NET-Framework-45-Features, RPC-over-HTTP-proxy, RSAT-Clustering, Web-Mgmt-Console, WAS-Process-Model, Web-Asp-Net45, Web-Basic-Auth, Web-Client-Auth, Web-Digest-Auth, Web-Dir-Browsing, Web-Dyn-Compression, Web-Http-Errors, Web-Http-Logging, Web-Http-Redirect, Web-Http-Tracing, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Lgcy-Mgmt-Console, Web-Metabase, Web-Mgmt-Console, Web-Mgmt-Service, Web-Net-Ext45, Web-Request-Monitor, Web-Server, Web-Stat-Compression, Web-Static-Content, Web-Windows-Auth, Web-WMI, Windows-Identity-Foundation
pause
Write-Host -f green "Prerequisites completed, press any key to restart..."
Restart-Computer