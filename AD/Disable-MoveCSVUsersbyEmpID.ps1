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
    [parameter(Position=0,Mandatory=$true,ValueFromPipeline=$false,HelpMessage='Please enter SRQ Number')][string]$SRQNumber
)

 
$transcriptname = "DisableCSVUsers" + `
    (Get-Date -format s).Replace(":","-") +".txt"
Start-Transcript $transcriptname


$date=(get-date).AddDays(+90).ToString("yyy-MM-dd")
$DelName="Delete on "
$SRQ=" SRQ "
$Del="Delete on "

$OUname=$Delname+$date

# Create AD Ou based on Deleted Date
New-ADOrganizationalUnit -Name $OUname -Path "OU=Disabled to be Deleted,DC=mccarthyltd,DC=local" -ProtectedFromAccidentalDeletion $false 
$date=(get-date).ToString("yyy-MM-dd")

#Request SRQ from User for current Action
#$SRQNo=Read-host "Enter SRQ Number"
$SRQNo=$SRQNumber
$Desc=$del+$date+$SRQ+$SRQNo


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

#Set AD User's Description based on date and SRQ
set-ADUser -Identity $EMPUser.SamAccountName -Description $Desc -ErrorAction SilentlyContinue 

#Set User to Disabled
Set-ADAccountControl -Identity $EMPUser.SamAccountName -Enabled -ErrorAction SilentlyContinue $false -whatif

#Move User into created Disabled OU based on date
Get-aduser $EMPUser.SamAccountName | Move-ADObject -TargetPath "OU=$OUName,OU=Disabled to be Deleted,DC=mccarthyltd,DC=local" -whatif
}

Stop-Transcript