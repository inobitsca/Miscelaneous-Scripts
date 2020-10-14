<#
    .SYNOPSIS
    Imports Employee ID's from a CSV file and add them to a specified group.
   
   	Authors: Cedric Abrahams & Brendan Thompson for Netsurit
    
	THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE 
	RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.
	CODE MAY NOT BE COPIED, REUSED OR MODIFIED WITHOUT EXPRESS CONSENT OF AUTHOR.
	
	Version 1.0.1, 09 Dec 2014
	
    .DESCRIPTION
	
    This Script imports a user specified CSV file and then performs removal actions for users who have left
    
    .PARAMETER ImportFile
    File to be Imported
    

    .EXAMPLE
    Add users to Group from CSV
    .\AddToGroupByEmpID.ps1 -Importfile employeeids.csv -GroupName "GroupName"
#>

#Request Group Name from User for current Action
$GroupName=Read-host "Enter Group Name"

#Request CSV file Name from User for current Action
$ImportFile=Read-host "Enter CSV File Name"

$transcriptname = "AddToGroupByEmpID" + (Get-Date -format s).Replace(":","-") +".txt"
Start-Transcript $transcriptname

$TempCSVname = ".\" +"TempCSV" + (Get-Date -format d) +".csv"


Write-Host "Reading in CSV File..." -ForegroundColor Yellow
#Import CSV with List of Employee ID's
$importEMPIDS=Import-csv $ImportFile



Write-Host "Processing Users.." -ForegroundColor Yellow
#For Each Employee ID Perform the Following Actions
foreach ($ImportEMPID in $ImportEMPIDS)
{

#Convert Employee ID to a String (Needed for AD Filter, it only takes string inputs)
$EMPIDString = $ImportEMPID.EmpID.ToString()

#Search AD for Employee ID's stored in the Pager field
$EMPUser = Get-ADUser -Filter 'Pager -eq $EMPIDString' -properties * | export-csv $TempCSVname -append -force
}



Write-Host "Adding Users to specified Group"
#Move User into created desired group
Import-CSV $TempCSVname | % {add-Adgroupmember -Identity $GroupName -members $_.SamAccountname -Confirm:$false }

write-host "Completed adding users to the specified group." -ForegroundColor Green

del $TempCSVname

Stop-Transcript


