<#
    .SYNOPSIS
    Imports Employee ID's from a CSV file and hides the Account from the Exchange 2003 GAL 
   
   	Authors: Cedric Abrahams & Brendan Thompson for Netsurit
    
	THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE 
	RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.
	CODE MAY NOT BE COPIED, REUSED OR MODIFIED WITHOUT EXPRESS CONSENT OF AUTHOR.
	
	Version 1.0.7, 13 May 2014
	
    .DESCRIPTION
	
    This Script imports a user specified CSV file and then performs removal actions for users who have left
    
    .PARAMETER ImportFile
    File to be Imported
    

    .EXAMPLE
    Hide Users from GAL
    .\HideFromGALCSVbyEmpID.ps1 -Importfile employeeids.csv 
#>


param(
    [parameter(Position=0,Mandatory=$true,ValueFromPipeline=$false,HelpMessage='Filename to Import')][string]$ImportFile
)

 
$transcriptname = "HideCSVUsers" + `
    (Get-Date -format s).Replace(":","-") +".txt"
Start-Transcript $transcriptname


Write-Host "Reading in CSV File..." -ForegroundColor Green
#Import CSV with List of Employee ID's
$importEMPIDS=Import-csv $ImportFile


Write-Host "Processing Users.." -ForegroundColor Green
#For Each Employee ID Perform the Following Actions
foreach ($ImportEMPID in $ImportEMPIDS)
{

#Convert Employee ID to a String (Needed for AD Filter, it only takes string inputs)
$EMPIDString = $ImportEMPID.EmpID.ToString()

#Search AD for Employee ID's stored in the Pager field
$EMPUser = Get-ADUser -Filter 'Pager -eq $EMPIDString' -properties *

#Set Hide from Address Book
set-ADUser -Identity $EMPUser MSExchHideFromAddressLists = TRUE -ErrorAction SilentlyContinue 

}

Stop-Transcript