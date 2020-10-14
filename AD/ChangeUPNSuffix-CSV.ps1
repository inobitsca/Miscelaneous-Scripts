
<#
    .SYNOPSIS
    Imports Employee ID's from a CSV file and changes the UPN suffix according to the email suffix.
    CSV file requires the following columns: SamAccountname, UPNSuffix, EmailSuffix, UserPrincipalName
These values are the current values. 
   
   	Authors: Cedric Abrahams for Netsurit
    
	THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE 
	RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.
	CODE MAY NOT BE COPIED, REUSED OR MODIFIED WITHOUT EXPRESS CONSENT OF AUTHOR.
	
	Version 1.0.0, 2015-01-05
	
    .DESCRIPTION
	
    This Script imports a user specified CSV file and then performs removal actions for users who have left
    
    .PARAMETER ImportFile
    File to be Imported
    

    .EXAMPLE
     .\ChangeUPNSuffix-CSV.ps1 -Importfile employeeids.csv
#>

param(
    [parameter(Position=0,Mandatory=$true,ValueFromPipeline=$false,HelpMessage='Filename to Import')][string]$ImportFile
)


$transcriptname = "ChangeUPNSuffix" + `
    (Get-Date -format s).Replace(":","-") +".txt"
Start-Transcript $transcriptname

Write-Host "Reading in CSV File..." -ForegroundColor Green
#Import CSV with List of UserID's

$importEMPIDS=import-csv $ImportFile

Write-Host "Processing Users.." -ForegroundColor Green
#For Each Employee ID Perform the Following Actions

foreach ($ImportEMPID in $ImportEMPIDS)
{

$UserID = $ImportEMPID.SamAccountname
$oldSuffix = $ImportEMPID.UPNSuffix
$NewSuffix=  $ImportEMPID.emailsuffix
$UserUPN = $ImportEMPID.Userprincipalname


Write-Host $oldSuffix 
Write-Host $NewSuffix 
Write-Host $UserID 
Write-Host $UserUPN

$newUpn = $UserUPN.Replace($oldSuffix,$newSuffix)



Set-ADUser -identity $UserID -UserPrincipalName $newUpn


}

Stop-transcript