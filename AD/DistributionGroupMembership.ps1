<#
    .SYNOPSIS
    Lists members of distribution Groups to a Text file 
   
   	Authors: Cedric Abrahams & Brendan Thompson for Netsurit
    
	THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE 
	RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.
	CODE MAY NOT BE COPIED, REUSED OR MODIFIED WITHOUT EXPRESS CONSENT OF AUTHOR.
	
	Version 1.0.0, 2014-06-25
	
    .DESCRIPTION
	
    This Script createsa a temporary CSV file with all distributiongroups in the domain, then lists all members of each group in a text file
    
    .PARAMETER ExportFile
    File to be Exported
    

    .EXAMPLE
    Get Group Membership
    .\DistributionGroupMembership.ps1 -Exportfile DisGroupMembers.txt
#>

param(
    [parameter(Position=0,Mandatory=$true,ValueFromPipeline=$false,HelpMessage='Filename to Export')][string]$ExportFile
   )

get-adgroup -filter {groupType -eq "2"} |export-csv c:\temp\groupnames.csv
import-csv C:\Temp\groupnames.csv | % {Get-ADGroupMember -Identity $_.SamAccountName | FT $_.SamAccountName,name,SamAccountname} >$ExportFile
del c:\temp\groupnames.csv