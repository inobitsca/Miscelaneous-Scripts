<# 
script name: DbaChecks.ps1 
  
Gather info of daily interest on SQL Servers and email and attachment it. 
  
01/12/18 - original script - Joe Gavin 
#> 
  
$WorkDir = "C:\Temp\dbachecks" 
$OutFile = "DbaChecks.txt" 

# delete old out file 
If (Test-Path "$WorkDir\$OutFile"){Remove-Item "$WorkDir\$OutFile"} 
  
  

# Edit names in arrays in alphabetical order for ordered output. Windows server names and SQL Server names are not sorted in script as edits are infrequent. 
# Windows machine names 
[array]$WinMachines = @("PRSQL01","PRSQL02","DRSQL01") 
  
# SQL Server instance names 
[array]$SqlServers = @("PRSQL01\MSSQLSERVER","PRSQL02\MSSQLSERVER","DRSQL01\MSSQLSERVER") 
  
# mail variables 
$PSEmailServer = "za-smtp-inbound-1.mimecast.co.za" 
$MailFrom = "SQLtest@ncems.co.za" 
$MailTo = "cedrica@inobits.com" 
$MailSubject = "EVO NCEMS DBA Checks" 
  
# begin 
  
Set-Location $WorkDir 
   
# test connectivity to each Win machine 
function TestConn{ 
Add-Content $WorkDir\$OutFile "Testing connectivity...`n" 
Foreach ($WinMachine in $WinMachines)  
{ 
   If (Test-Connection -Computer $WinMachine -Quiet) {Add-Content $WorkDir\$OutFile "`n$WinMachine responded`n"}  
   Else {Add-Content $WorkDir\$OutFile "`n$WinMachine not responding`n"} 
}Add-Content $WorkDir\$OutFile "`n" 
}  
  
# ServerInfo 
function ServerInfo{ 
Foreach ($SqlServer in $SqlServers) 
{ 
   sqlcmd -E -W -S $SqlServer -i $WorkDir\ServerInfo.sql | Out-File -FilePath "$WorkDir\$OutFile" -Append 
}} 
  
# ErrorLogs 
function ErrorLogs{ 
Foreach ($SqlServer in $SqlServers) 
{ 
   sqlcmd -E -W -S $SqlServer -i $WorkDir\ErrorLogs.sql | Out-File -FilePath "$WorkDir\$OutFile" -Append 
}} 
  
# DiskSpace 
function DiskSpace{ 
Foreach ($WinMachine in $WinMachines)  
{  
  $error.clear() 
  Get-WmiObject -Class win32_volume -cn $WinMachine -filter "DriveType=3" | Select-Object @{LABEL='Machine';EXPRESSION={$WinMachine}},driveletter, @{LABEL='GBcapacity';EXPRESSION={"{0:N1}" -f ($_.capacity/1GB)}}, @{LABEL='%utilized';EXPRESSION={"{0:N2}" -f (100 - $_.freespace/$_.capacity*100)}} | Where-Object {$_.GBcapacity -gt 20} | Sort-Object driveletter | Out-File -FilePath "$WorkDir\$OutFile" -Append    
  $error | Out-File -FilePath "$WorkDir\$OutFile" -Append # write any PowerShell errors to out file 
  $error.clear()     # clear variable so it can be used in other functions 
}} 
   

# datestamp 
$HostName = hostname 
Write-Output "Report run from $HostName started $(get-date)  `r`n" | Out-File -FilePath "$WorkDir\$OutFile" -Append 
  
# call functions or comment out to not run 
TestConn 
ServerInfo 
ErrorLogs 
DiskSpace 
  
# email report file 
Send-MailMessage -From $MailFrom -To $MailTo -Subject $MailSubject -Attachments $OutFile 
