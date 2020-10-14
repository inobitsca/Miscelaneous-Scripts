<#  
.SYNOPSIS  
   	Configures the necessary prerequisites to install Exchange 2010 on a Windows Server 2008 R2 server

.DESCRIPTION  
    Installs all required Windows 2008 R2 components, the filter pack, and configures service startup settings. Provides options for disabling TCP/IP v6, downloading latest Update Rollup, etc.

.NOTES  
    Version      				: 3.3 - See changelog at http://www.ehloworld.com/591 
		Wish list						: loopback adapter    										
												: better comment based help
												: static port mapping
												: event log logging
    Rights Required			: Local admin on server
    Sched Task Req'd		: No
    Exchange Version		: 2010
    Author       				: Pat Richard, Exchange MVP
    Email/Blog/Twitter	: pat@innervation.com 	http://www.ehloworld.com @patrichard
    Dedicated Blog			: http://www.ehloworld.com/152
    Disclaimer   				: You running this script means you won't blame me if this breaks your stuff.
    Info Stolen from 		: Anderson Patricio and Bhargav Shukla
    										: http://msmvps.com/blogs/andersonpatricio/archive/2009/11/13/installing-exchange-server-2010-pre-requisites-on-windows-server-2008-r2.aspx
												: http://www.bhargavs.com/index.php/powershell/2009/11/script-to-install-exchange-2010-pre-requisites-for-windows-server-2008-r2/
.LINK  
    http://www.ehloworld.com/152

.EXAMPLE
	.\Set-Exchange2010Features.ps1

.INPUTS
	None. You cannot pipe objects to this script.
#>
#Requires -Version 2.0
param(
	[parameter(ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$false, Mandatory=$false)] 
	[string] $strFilenameTranscript = $MyInvocation.MyCommand.Name + " " + (hostname)+ " {0:yyyy-MM-dd hh-mmtt}.log" -f (Get-Date),
	[parameter(ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$true, Mandatory=$false)] 
	[string] $TargetFolder = "c:\Install",
	# [string] $TargetFolder = $Env:Temp
	[parameter(ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$false, Mandatory=$false)] 
	[bool] $WasInstalled = $false,
	[parameter(ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$false, Mandatory=$false)] 
	[bool] $RebootRequired = $false,
	[parameter(ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$false, Mandatory=$false)] 
	[string] $opt = "None",
	[parameter(ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$false, Mandatory=$false)] 
	[bool] $HasInternetAccess = ([Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}')).IsConnectedToInternet)
)

Start-Transcript -path .\$strFilenameTranscript | Out-Null
$error.clear()
# Detect correct OS here and exit if no match (we intentionally truncate the last character to account for service packs)
if ((Get-WMIObject win32_OperatingSystem).Version -notmatch '6.1.760'){
	Write-Host "`nThis script requires a version of Windows Server 2008 R2, which this is not. Exiting...`n" -ForegroundColor Red
	Exit
}
Clear-Host
Pushd
# determine if BitsTransfer is already installed
if ((Get-Module BitsTransfer).installed -eq $true){
	[bool] $WasInstalled = $true
}else{
	[bool] $WasInstalled = $false
}
[string] $menu = @'

	*******************************************
	Exchange Server 2010 - Features script
	*******************************************
	
	Please select an option from the list below.
	
	1) install Hub Transport prerequisites
	2) install Client Access Server prerequisites
	3) install Mailbox prerequisites
	4) install Unified Messaging prerequisites
	5) install Edge Transport prerequisites
	6) install Typical (CAS/HUB/Mailbox) prerequisites
	7) install Typical (CAS/HUB/Mailbox) prerequisites [No RPC-OVER-HTTP]	
	8) install Client Access and Hub Transport prerequisites
	9) Configure NetTCP Port Sharing service
	   (Required for the Client Access Server role
	   Automatically set for options 2,6,7,8, and 11)
	10) Install 2010 Office System Converter: Microsoft Filter Pack 2.0
	    (Required if installing Hub Transport or Mailbox Server roles
	    Automatically set for options 1,3,6,7,8, and 11)
	11) install Typical (CAS/HUB/Mailbox) prerequisites [with .PDF ifilter; disable IPv6]
	12) Download Exchange Server 2010 Service Pack 2
	13) Disable TCP/IP v6
	14) Install & Configure Adobe PDF Filter Pack
	15) Launch Windows Update	
	
	98) Restart the Server
	99) Exit

Select an option.. [1-99]?
'@

function Install-FilterPack{
    # Office filter pack
    if ((Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{95140000-2000-0409-1000-0000000FF1CE}") -eq $false){
    	GetIt "http://download.microsoft.com/download/0/A/2/0A28BBFA-CBFA-4C03-A739-30CCA5E21659/FilterPack64bit.exe"
    	Set-Location $targetfolder
    	[string]$expression = ".\FilterPack64bit.exe /quiet /norestart /log:$targetfolder\FilterPack64bit.log"
    	Write-Host "File: FilterPack64bit.exe installing..." -NoNewLine
    	Invoke-Expression $expression
    	Start-Sleep -Seconds 20
    	if ((Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{95140000-2000-0409-1000-0000000FF1CE}") -eq $true){Write-Host "`b`b`b`b`b`b`b`b`b`b`b`b`binstalled!   " -Foregroundcolor Green}else{Write-Host "`b`b`b`b`b`b`b`b`b`b`b`b`bFAILED!" -Foregroundcolor Red}
    }else{
    	Write-Host "`nOffice filter pack already installed" -Foregroundcolor Green
    } 
} # end Install-FilterPack

function Install-PDFFilterPack{
    # adobe ifilter
    if ((Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{5EA12CF3-8162-47F6-ACAF-45AD03EFB08F}") -eq $false){
    	GetIt "http://download.adobe.com/pub/adobe/acrobat/win/9.x/PDFiFilter64installer.zip"
    	UnZipIt "PDFiFilter64installer.zip" "PDFFilter64installer.msi"
    	Set-Location $targetfolder
    	[string]$expression = ".\PDFFilter64installer.msi /quiet /norestart /l* $targetfolder\PDFiFilter64Installer.log"
    	Write-Host "File: PDFFilter64installer.msi installing..." -NoNewLine
    	Invoke-Expression $expression
    	Start-Sleep -Seconds 20
    	if ((Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{5EA12CF3-8162-47F6-ACAF-45AD03EFB08F}") -eq $true){Write-Host "`b`b`b`b`b`b`b`b`b`b`b`b`binstalled!   " -Foregroundcolor Green}else{Write-Host "`b`b`b`b`b`b`b`b`b`b`b`b`bFAILED!" -Foregroundcolor Red}
    }else{
    	Write-Host "`nPDF filter pack already installed" -Foregroundcolor Green
    }
} # end Install-PDFFilterPack

function Configure-PDFFilterPack	{
	# Adobe iFilter Directory Path
	$iFilterDirName = "C:\Program Files\Adobe\Adobe PDF IFilter 9 for 64-bit platforms\bin"
	
	# Get the original path environment variable
	$original = (Get-ItemProperty "HKLM:SYSTEM\CurrentControlSet\Control\Session Manager\Environment" Path).Path
	
	# Add the ifilter path
	Set-ItemProperty "HKLM:SYSTEM\CurrentControlSet\Control\Session Manager\Environment" Path -value ( $original + ";" + $iFilterDirName )
	$CLSIDKey = "HKLM:\SOFTWARE\Microsoft\ExchangeServer\V14\MSSearch\CLSID"
	$FiltersKey = "HKLM:\SOFTWARE\Microsoft\ExchangeServer\v14\MSSearch\Filters"
	
	# Filter DLL Locations
	$pdfFilterLocation = "PDFFilter.dll"
	
	# Filter GUIDs
	$PDFGuid = "{E8978DA6-047F-4E3D-9C78-CDBE46041603}"
	
	# Create CLSIDs
	Write-Host "Creating CLSIDs..."
	New-Item -Path $CLSIDKey -Name $PDFGuid -Value $pdfFilterLocation -Type String
	
	# Set Threading model
	Write-Host "Setting threading model..."
	New-ItemProperty -Path "$CLSIDKey\$PDFGuid" -Name "ThreadingModel" -Value "Both" -Type String
	
	# Set Flags
	Write-Host "Setting Flags..."
	New-ItemProperty -Path "$CLSIDKey\$PDFGuid" -Name "Flags" -Value "1" -Type Dword
	
	# Create Filter Entries
	Write-Host "Creating Filter Entries..."
	
	# These are the entries for commonly exchange formats
	New-Item -Path $FiltersKey -Name ".pdf" -Value $PDFGuid -Type String
	Write-Host "Registry subkeys created. If this server holds the Hub Transport Role, the Network Service will need to have read access to the following registry keys:`n$CLSIDKey\$PDFGuid`n$FiltersKey\.pdf" -ForegroundColor Green
} # end function Configure-PDFFilterPack

function Set-RunOnce{
	# Sets the NetTCPPortSharing service for automatic startup before the first reboot
	# by using the old RunOnce registry key (because the service doesn't yet exist, or we could
	# use 'Set-Service')
	$hostname = (hostname)
	$RunOnceCommand1 = "sc \\$hostname config NetTcpPortSharing start= auto"
	if (Get-ItemProperty -Name "NetTCPPortSharing" -path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce' -ErrorAction SilentlyContinue) { 
	  Write-host "Registry key HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce\NetTCPPortSharing already exists." -ForegroundColor yellow
		Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name "NetTCPPortSharing" -Value $RunOnceCommand1 | Out-Null
	} else { 
	  New-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name "NetTCPPortSharing" -Value $RunOnceCommand1 -PropertyType "String" | Out-Null
	} 
} # end Set-RunOnce

function GetIt ([string]$sourcefile)	{
	if ($HasInternetAccess){
		# check if BitsTransfer is installed
		if ((Get-Module BitsTransfer) -eq $null){
			Write-Host "BitsTransfer: Installing..." -NoNewLine
			Import-Module BitsTransfer	
			Write-Host "`b`b`b`b`b`b`b`b`b`b`b`b`binstalled!   " -ForegroundColor Green
		}
		[string] $targetfile = $sourcefile.Substring($sourcefile.LastIndexOf("/") + 1) 
		if (Test-Path $targetfolder){
			Write-Host "Folder: $targetfolder exists."
		} else{
			Write-Host "Folder: $targetfolder does not exist, creating..." -NoNewline
			New-Item $targetfolder -type Directory | Out-Null
			Write-Host "`b`b`b`b`b`b`b`b`b`b`bcreated!   " -ForegroundColor Green
		}
		if (Test-Path "$targetfolder\$targetfile"){
			Write-Host "File: $targetfile exists."
		}else{	
			Write-Host "File: $targetfile does not exist, downloading..." -NoNewLine
			Start-BitsTransfer -Source "$SourceFile" -Destination "$targetfolder\$targetfile"
			Write-Host "`b`b`b`b`b`b`b`b`b`b`b`b`b`bdownloaded!   " -ForegroundColor Green
		}
	}else{
		Write-Host "Internet Access not detected. Please resolve and try again." -foregroundcolor red
	}
} # end GetIt

function UnZipIt ([string]$source, [string]$target){
	if (Test-Path "$targetfolder\$target"){
		Write-Host "File: $target exists."
	}else{
		Write-Host "File: $target doesn't exist, unzipping..." -NoNewLine
		$sh = new-object -com shell.application
		$zipfolder = $sh.namespace("$targetfolder\$source") 
		$item = $zipfolder.parsename("$target")      
		$targetfolder2 = $sh.namespace("$targetfolder")       
		Set-Location $targetfolder
		$targetfolder2.copyhere($item)
		Write-Host "`b`b`b`b`b`b`b`b`b`b`b`bunzipped!   " -ForegroundColor Green
		Remove-Item $source
	}
} # end UnZipIt

function Remove-IPv6	{
	$error.clear()
	Write-Host "TCP/IP v6......................................................[" -NoNewLine
	Write-Host "removing" -ForegroundColor yellow -NoNewLine
	Write-Host "]" -NoNewLine
	Set-ItemProperty -path HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters -name DisabledComponents -value 0xffffffff -type dword
	if ($error){
		Write-Host "`b`b`b`b`b`b`b`bfailed!" -ForegroundColor red -NoNewLine
	}else{
		Write-Host "`b`b`b`b`b`b`b`b`bdone!" -ForegroundColor green -NoNewLine
	}
	Write-Host "]    "
	$global:boolRebootRequired = $true
} # end function Remove-IPv6

function Get-ModuleStatus { 
	param	(
		[parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$true, HelpMessage="No module name specified!")] 
		[string]$name
	)
	if(!(Get-Module -name "$name")) { 
		if(Get-Module -ListAvailable | ? {$_.name -eq "$name"}) { 
			Import-Module -Name "$name" 
			# module was imported
			return $true
		} else {
			# module was not available
			return $false
		}
	}else {
		# module was already imported
		# Write-Host "$name module already imported"
		return $true
	}
} # end function Get-ModuleStatus

function New-FileDownload {
	param (
		[parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$true, HelpMessage="No source file specified")] 
		[string]$SourceFile,
    [parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$false, HelpMessage="No destination folder specified")] 
    [string]$DestFolder,
    [parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$false, HelpMessage="No destination file specified")] 
    [string]$DestFile
	)
	# I should clean up the display text to be consistent with other functions
	$error.clear()
	if (!($DestFolder)){$DestFolder = $TargetFolder}
	Get-ModuleStatus -name BitsTransfer
	if (!($DestFile)){[string] $DestFile = $SourceFile.Substring($SourceFile.LastIndexOf("/") + 1)}
	if (Test-Path $DestFolder){
		Write-Host "Folder: `"$DestFolder`" exists."
	} else{
		Write-Host "Folder: `"$DestFolder`" does not exist, creating..." -NoNewline
		New-Item $DestFolder -type Directory
		Write-Host "Done! " -ForegroundColor Green
	}
	if (Test-Path "$DestFolder\$DestFile"){
		Write-Host "File: $DestFile exists."
	}else{
		if ($HasInternetAccess){
			Write-Host "File: $DestFile does not exist, downloading..." -NoNewLine
			Start-BitsTransfer -Source "$SourceFile" -Destination "$DestFolder\$DestFile"
			Write-Host "Done! " -ForegroundColor Green
		}else{
			Write-Host "Internet access not detected. Please resolve and try again." -ForegroundColor red
		}
	}
} # end function New-FileDownload

Do { 	
	if ($RebootRequired -eq $true){Write-Host "`t`t`t`t`t`t`t`t`t`n`t`t`t`tREBOOT REQUIRED!`t`t`t`n`t`t`t`t`t`t`t`t`t`n`t`tDO NOT INSTALL EXCHANGE BEFORE REBOOTING!`t`t`n`t`t`t`t`t`t`t`t`t" -backgroundcolor red -foregroundcolor black}
	if ($opt -ne "None") {Write-Host "Last command: "$opt -foregroundcolor Yellow}	
	$opt = Read-Host $menu

	switch ($opt)    {
		1 { # install Hub Transport prerequisites
			Get-ModuleStatus -name ServerManager
			Install-FilterPack
			Add-WindowsFeature NET-Framework,RSAT-ADDS,Web-Server,Web-Basic-Auth,Web-Windows-Auth,Web-Metabase,Web-Net-Ext,Web-Lgcy-Mgmt-Console,WAS-Process-Model,RSAT-Web-Server
			$RebootRequired = $true 
		}
		2 { # install Client Access Server prerequisites
			Get-ModuleStatus -name ServerManager
			Set-RunOnce
			Add-WindowsFeature NET-Framework,RSAT-ADDS,Web-Server,Web-Basic-Auth,Web-Windows-Auth,Web-Metabase,Web-Net-Ext,Web-Lgcy-Mgmt-Console,WAS-Process-Model,RSAT-Web-Server,Web-ISAPI-Ext,Web-Digest-Auth,Web-Dyn-Compression,Web-WMI,NET-HTTP-Activation,Web-Asp-Net,Web-Client-Auth,Web-Dir-Browsing,Web-Http-Errors,Web-Http-Logging,Web-Http-Redirect,Web-Http-Tracing,Web-ISAPI-Filter,Web-Request-Monitor,Web-Static-Content,Web-WMI,RPC-Over-HTTP-Proxy
			$RebootRequired = $true 
		}
		3 { # install Mailbox prerequisites
			Get-ModuleStatus -name ServerManager
			Install-FilterPack
			Add-WindowsFeature NET-Framework,RSAT-ADDS,Web-Server,Web-Basic-Auth,Web-Windows-Auth,Web-Metabase,Web-Net-Ext,Web-Lgcy-Mgmt-Console,WAS-Process-Model,RSAT-Web-Server
			$RebootRequired = $true 
		}
		4 { # install Unified Messaging prerequisites
			Get-ModuleStatus -name ServerManager
			Add-WindowsFeature NET-Framework,RSAT-ADDS,Web-Server,Web-Basic-Auth,Web-Windows-Auth,Web-Metabase,Web-Net-Ext,Web-Lgcy-Mgmt-Console,WAS-Process-Model,RSAT-Web-Server,Desktop-Experience
			$RebootRequired = $true 
		}
		5 { # install Edge Transport prerequisites
			Get-ModuleStatus -name ServerManager
			Add-WindowsFeature NET-Framework,RSAT-ADDS,ADLDS
			$RebootRequired = $true 
		}
		6 { # install Typical (CAS/HUB/Mailbox) prerequisites
			Get-ModuleStatus -name ServerManager
			Set-RunOnce
			Install-FilterPack
			Add-WindowsFeature NET-Framework,RSAT-ADDS,Web-Server,Web-Basic-Auth,Web-Windows-Auth,Web-Metabase,Web-Net-Ext,Web-Lgcy-Mgmt-Console,WAS-Process-Model,RSAT-Web-Server,Web-ISAPI-Ext,Web-Digest-Auth,Web-Dyn-Compression,NET-HTTP-Activation,Web-Asp-Net,Web-Client-Auth,Web-Dir-Browsing,Web-Http-Errors,Web-Http-Logging,Web-Http-Redirect,Web-Http-Tracing,Web-ISAPI-Filter,Web-Request-Monitor,Web-Static-Content,Web-WMI,RPC-Over-HTTP-Proxy
			$RebootRequired = $true 
		}
		7 { # install Typical (CAS/HUB/Mailbox) prerequisites [No RPC-OVER-HTTP]
			Get-ModuleStatus -name ServerManager
			Set-RunOnce
			Install-FilterPack
			Add-WindowsFeature NET-Framework,RSAT-ADDS,Web-Server,Web-Basic-Auth,Web-Windows-Auth,Web-Metabase,Web-Net-Ext,Web-Lgcy-Mgmt-Console,WAS-Process-Model,RSAT-Web-Server,Web-ISAPI-Ext,Web-Digest-Auth,Web-Dyn-Compression,NET-HTTP-Activation,Web-Asp-Net,Web-Client-Auth,Web-Dir-Browsing,Web-Http-Errors,Web-Http-Logging,Web-Http-Redirect,Web-Http-Tracing,Web-ISAPI-Filter,Web-Request-Monitor,Web-Static-Content,Web-WMI
			$RebootRequired = $true 
		}
		8 { # install Client Access and Hub Transport prerequisites
			Get-ModuleStatus -name ServerManager
			Set-RunOnce
			Install-FilterPack
			Add-WindowsFeature NET-Framework,RSAT-ADDS,Web-Server,Web-Basic-Auth,Web-Windows-Auth,Web-Metabase,Web-Net-Ext,Web-Lgcy-Mgmt-Console,WAS-Process-Model,RSAT-Web-Server,Web-ISAPI-Ext,Web-Digest-Auth,Web-Dyn-Compression,NET-HTTP-Activation,Web-Asp-Net,Web-Client-Auth,Web-Dir-Browsing,Web-Http-Errors,Web-Http-Logging,Web-Http-Redirect,Web-Http-Tracing,Web-ISAPI-Filter,Web-Request-Monitor,Web-Static-Content,Web-WMI,RPC-Over-HTTP-Proxy
			$RebootRequired = $true 
		}
		9 { # Configure NetTCP Port Sharing service
			Set-Service NetTcpPortSharing -StartupType Automatic
			Write-Host "done!" -ForegroundColor Green 
		}
		10 { # Install 2010 Office System Converter: Microsoft Filter Pack 2.0
			Install-FilterPack 
		}
		11 { # install Typical (CAS/HUB/Mailbox) prerequisites [with .PDF ifilter; disable IPv6]
			Get-ModuleStatus -name ServerManager
			Set-RunOnce
			Install-FilterPack
			Install-PDFFilterPack
			Configure-PDFFilterPack
			Add-WindowsFeature NET-Framework,RSAT-ADDS,Web-Server,Web-Basic-Auth,Web-Windows-Auth,Web-Metabase,Web-Net-Ext,Web-Lgcy-Mgmt-Console,WAS-Process-Model,RSAT-Web-Server,Web-ISAPI-Ext,Web-Digest-Auth,Web-Dyn-Compression,NET-HTTP-Activation,Web-Asp-Net,Web-Client-Auth,Web-Dir-Browsing,Web-Http-Errors,Web-Http-Logging,Web-Http-Redirect,Web-Http-Tracing,Web-ISAPI-Filter,Web-Request-Monitor,Web-Static-Content,Web-WMI,RPC-Over-HTTP-Proxy
			Remove-IPv6
			$RebootRequired = $true 
		}
		12 { # Download Exchange Server 2010 Service Pack 2
			GetIt "http://download.microsoft.com/download/F/5/F/F5FADCEF-D96B-48C4-ADD9-067FDB1AEDB6/Exchange2010-SP2-x64.exe"
		}
	  13 { # Disable TCP/IP v6
	   	Remove-IPv6 
	  }
	  14	{ # Install & Configure PDF Filter Pack
	  	Install-PDFFilterPack
			Configure-PDFFilterPack
	  }
	  15	{ # Windows Update
			Invoke-Expression "$env:windir\system32\wuapp.exe startmenu"
		}
		98 { # Exit and restart
			Stop-Transcript
			Restart-Computer 
		}
		99 { # Exit
			if (($WasInstalled -eq $false) -and (Get-Module BitsTransfer)){
				Write-Host "BitsTransfer: Removing..." -NoNewLine
				Remove-Module BitsTransfer
				Write-Host "`b`b`b`b`b`b`b`b`b`b`bremoved!   " -ForegroundColor Green
			}
			popd
			Write-Host "Exiting..."
			Stop-Transcript
		}
		default {Write-Host "You haven't selected any of the available options. "}
	}
} while ($opt -ne 99)