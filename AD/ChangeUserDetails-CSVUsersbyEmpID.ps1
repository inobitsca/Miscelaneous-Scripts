<#
    .SYNOPSIS
    Imports Employee ID's from a CSV file and Disables the Account, and moves to a OU with the date to be deleted 
   
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
    Disable Users from CSV
    .\Disable-CSVUsers.ps1 -Importfile employeeids.csv -SRQNumber 876533
#>


param(
    [parameter(Position=0,Mandatory=$true,ValueFromPipeline=$false,HelpMessage='Filename to Import')][string]$ImportFile,
)

 
$transcriptname = "ChangeCSVUsers" + `
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
$BUString = $ImportEMPID.BU.ToString()
$DeptString = $ImportEMPID.Department.ToString()
$TitleString = $ImportEMPID.JobTitle.ToString()

#Search AD for Employee ID's stored in the Pager field
$EMPUser = Get-ADUser -Filter 'Pager -eq $EMPIDString' -properties *

#Set AD User's Description based CSV
set-ADUser -Identity $EMPUser.SamAccountName -Department $DeptString -Title $TitleString -Company $BUString -ErrorAction SilentlyContinue -whatif 


}

Stop-Transcript