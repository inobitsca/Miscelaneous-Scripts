<#
Description:
This script gathers AADSync information from various locations and reports to the screen.
 
Script originally written for DirSync on November 5, 2013 by Mike Crowley
http://mikecrowley.us
 
Modified by Michael Van Horenbeeck on October 21, 2014
 
Example:
 
 GetAADSyncInfo.ps1 -filePath c:\temp\
 
This will generate an HTML file called "AADSyncInfo.html" in the folder c:\temp
 
Changes:
1) Modified to work with Azure AD Sync tool
2) Updated source for Service Account Guess. Information comes now from internal SQL DB instead of local registry
3) Removed features that are not included in the Sept. 2014 release of Azure AD Sync
4) Script will now generate an HTML report rather than relying on an interactive output on the screen
 
Known Issues:
1) All commands, including SQL queries run as the local user.  This may cause issues on locked-down SQL deployments.
2) For remote SQL installations, the SQL PowerShell module must be installed on the dirsync server.
    (http://technet.microsoft.com/en-us/library/hh231683.aspx)
 
#>
 
[CmdletBinding()]
    [OutputType([int])]
    Param
    (
        #Specify the report file path
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
                   [Alias("ReportPath")]
                   [ValidateNotNullOrEmpty()]
                   $filePath
    )
 
#Functions
Function check-even ($num) {[bool]!($num%2)}
#borrowed from http://blogs.technet.com/b/heyscriptingguy/archive/2006/10/19/how-can-i-tell-whether-a-number-is-even-or-odd.aspx
 
#Console Prep
cls
Write-Host "Please wait..." -F Yellow
ipmo SQLps
 
#Check for SQL Module
if ((gmo sqlps) -eq $null) {
    write-host "The SQL PowerShell Module Is Not loaded.  Please install and try again" -F Red
    write-host "http://technet.microsoft.com/en-us/library/hh231683.aspx" -F Red
    Write-Host "Quitting..." -F Red; sleep 5; Break
    }
 
#Get Dirsync Registry Info
$DirsyncVersion = (gp 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\MicrosoftAzureADConnectionTool').DisplayVersion
$DirsyncPath = (gp 'HKLM:\SOFTWARE\Microsoft\MSOLCoExistence\CurrentVersion').InstallationPath
 
#AAD Sync does not support external SQL yet, hence static SQL config from localDB
$SQLServer = $env:computername
 
$SQLInstance = (gp 'HKLM:\SYSTEM\CurrentControlSet\services\ADSync\Parameters').SQLInstance
$ADSyncInstance = (gp 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server Local DB\Shared Instances\ADSync').InstanceName
 
$MSOLInstance = ("np:\\.\pipe\"+$ADSyncInstance+"\tsql\query")
$SQLVersion = Invoke-Sqlcmd -ServerInstance $MSOLInstance -Query "SELECT SERVERPROPERTY('productversion'), SERVERPROPERTY ('productlevel'), SERVERPROPERTY ('edition')"
 
#Get AD Management Agents
$ADMAxml = Invoke-Sqlcmd -ServerInstance $MSOLInstance -Query "SELECT [ma_id] ,[ma_name] ,[private_configuration_xml],[ma_type] FROM [ADSync].[dbo].[mms_management_agent]" | ? {$_.ma_type -eq 'AD'}
$individualADMAgent=@()
$MaName=@()
foreach($ADMAgent in $ADMAxml){
    [xml]($ADMAgent | select -Expand private_configuration_xml)
    $individualADMAgent += [xml]($ADMAgent | select -Expand private_configuration_xml)
    $maName += ($ADMAgent | select ma_name)
}
 
#Get DirSync Database Info
$SQLDirSyncInfo = Invoke-Sqlcmd -ServerInstance $MSOLInstance -Query "SELECT DB_NAME(database_id) AS DatabaseName, Name AS Logical_Name, Physical_Name, (size*8)/1024 SizeMB FROM sys.master_files WHERE DB_NAME(database_id) = 'AdSync'"
$DirSyncDB = $SQLDirSyncInfo | ? {$_.Logical_Name -eq 'ADSync'}
$DirSyncLog = $SQLDirSyncInfo | ? {$_.Logical_Name -eq 'ADSync_log'}
 
#Get connector space info (optional)
$ADMA = Invoke-Sqlcmd -ServerInstance $MSOLInstance -Query "SELECT [ma_id] ,[ma_name],[ma_type] FROM [ADSync].[dbo].[mms_management_agent] WHERE ma_type = 'AD'"
$AzureMA = Invoke-Sqlcmd -ServerInstance $MSOLInstance -Query "SELECT [ma_id] ,[ma_name],[subtype],[private_configuration_xml] FROM [ADSync].[dbo].[mms_management_agent] WHERE subtype = 'Windows Azure Active Directory (Microsoft)'"
$UsersFromBothMAs = Invoke-Sqlcmd -ServerInstance $MSOLInstance -Query "SELECT [ma_id] ,[rdn] FROM [ADSync].[dbo].[mms_connectorspace] WHERE object_type = 'user'"
$AzureUsers = $UsersFromBothMAs | ? {$_.ma_id -eq $AzureMA.ma_id}
#$ADUsers = $UsersFromBothMAs | ? {$_.ma_id -eq $ADMA.ma_id}
 
#Get DirSync Run History
$SyncHistory = Invoke-Sqlcmd -ServerInstance $MSOLInstance -Query "SELECT [step_result] ,[end_date] ,[stage_no_change] ,[stage_add] ,[stage_update] ,[stage_rename] ,[stage_delete] ,[stage_deleteadd] ,[stage_failure] FROM [ADSync].[dbo].[mms_step_history]" | sort end_date -Descending
 
#GetDirSync interval (3 hours is default)
#AADSync uses Task Scheduler to get interval
$SyncTimeInterval = ((Get-ScheduledTaskInfo "Azure AD Sync Scheduler").NextRunTime - (Get-ScheduledTaskInfo "Azure AD Sync Scheduler").LastRunTime).TotalMinutes
 
#Generate Output
cls
 
#HTML HEADERS
$html += "<html>"
    $html += "<head>"
        $html += "<style type='text/css'>"
            $html += "body {font-family:verdana;font-size:10pt}"
            $html += "table {border:0px solid #000000;font-family:verdana; font-size:10pt;cellspacing:1;cellspacing:0}"
            $html += "tr.color {background-color:#00A2E8;color:#FFFFFF;font-weight:bold}"
            $html += "tr.title {background-color:#E5E5E5;text-decoration:underline}"
            $html += "font.value {color:#808080}"
        $html += "</style>"
    $html += "</head>"
    $html += "<body>"
 
    $html += "<b>Azure AADSync Report Info</b><br/>"
    $html += "Date: <font class='value'>"+(Get-Date)+"</font></br>"
    $html += "Server: <font class='value'>"+$env:computername+"</font></br>"
    $html += "<p>&nbsp;</p>"
 
    $html += "<b>Account info</b><br/>"
 
    #Get Account Info for each domain:
    #$ServiceAccountGuess = (((gci 'hkcu:Software\Microsoft\MSOIdentityCRL\UserExtendedProperties' | select PSChildName)[-1]).PSChildName -split ':')[-1]
    #Update to use info from SQL
    $ServiceAccountGuess = (([xml]$AzureMA.private_configuration_xml | select -ExpandProperty MaConfig | select -ExpandProperty parameter-values).parameter | ? Name -eq "username").'#text'
 
    $i=0
    foreach ($agent in $individualADMAgent){
        $ADServiceAccountUser = $Agent.'adma-configuration'.'forest-login-user'
        $ADServiceAccountDomain = $Agent.'adma-configuration'.'forest-login-domain'
        $ADServiceAccount = $ADServiceAccountDomain + "\" + $ADServiceAccountUser
 
        $html += "Active Directory Service Account <font class='value'>"+$ADServiceAccountDomain+": "+$ADServiceAccount+"</font>"
        $html += "<br/>"
        #Write-Host "Active Directory Service Account $ADServiceAccountDomain : " -F Cyan -NoNewline ; Write-Host $ADServiceAccount -F DarkCyan
 
        $i++
    }
    $html += "Azure Service Account Guess: <font class='value'>"+$ServiceAccountGuess+"</font>"
    #Write-Host "Azure Service Account Guess: " -F Cyan -NoNewline ; Write-Host $ServiceAccountGuess -F DarkCyan
    $html += "<p>&nbsp;</p>"
 
    $html += "<b>Azure AD Sync Info</b><br/>"
    $html += "Version: <font class='value'>"+$DirsyncVersion+"</font><br/>"
    $html += "Path: <font class='value'>"+$DirsyncPath+"</font><br/>"
    $html += "Sync Interval (Minutes): <font class='value'>"+$SyncTimeInterval+"</font>"
    $html += "<p>&nbsp;</p>"
 
    $html += "<b>User Info:</b><br/>"
 
    foreach($ad in $ADMA){
        $html += "User in AD "+$ad.ma_name+": <font class='value'>"+($UsersFromBothMAs | ? {$_.ma_id -eq $ad.ma_id}).count+"</font><br/>"
        #Write-Host "Users in AD"$ad.ma_name": " -F Cyan -NoNewLine ; Write-Host ($UsersFromBothMAs | ? {$_.ma_id -eq $ad.ma_id}).count -ForegroundColor DarkCyan
    }
 
    $html += "Users in Azure Connector Space: <font class='value'>"+$AzureUsers.Count+"</font><br/>"
    $html += "Total users: <font class='value'>"+$UsersFromBothMAs.Count+"</font><br/>"
    $html += "<p>&nbsp;</p>"
 
    $html += "<b>SQL Info</b><br/>"
    $html += "Version: <font class='value'>"+$SQLVersion.Column1+" "+$SQLVersion.Column2+" "+$SQLVersion.Column3+"</font><br/>"
    $html += "Instance: <font class='value'>"+$MSOLInstance+"</font><br/>"
    $html += "Database Location: <font class='value'>"+$DirSyncDB.Physical_Name+"</font><br/>"
    $html += "Database Size: <font class='value'>"+$DirSyncDB.SizeMB+"MB</font><br/>"
    $html += "Database Log Size: <font class='value'>"+$DirSyncLog.SizeMB+"MB</font>"
    $html += "<p>&nbsp;</p>"
 
    $html += "<b>Most Recent Sync Activity</b><br/>"
    $html += "<i>(For more detail, launch:"+$DirsyncPath+"\UIShell\miisclient.exe)<br/><br/>"
    $html += "<table>"
    $html += "<tr class='title'>"
        $html += "<td width='250'>"
            $html += "Date"
        $html += "</td>"
        $html += "<td>"
            $html += "Result"
        $html += "</td>"
    $html += "</tr>"
    for($j=0;$j -ne 9;$j++){
    if(check-even $j -eq $true){
        $color = "#C3C3C3"
    }
    else{
        $color = "#E5E5E5"
    }
        $html += "<tr style='background-color:$color'>"
            $html += "<td>"
                $html += ($SyncHistory[$j].end_date).ToLocalTime()
            $html += "</td>"
            $html += "<td>"
                $html += $SyncHistory[$j].step_result+"<br/>"
            $html += "</td>"
        $html += "</tr>"
    }
    $html += "</table>"
    $html += "<p>&nbsp;</p>"
 
    $html += "</body>"
$html += "</html>"
 
$filePath.TrimEnd("\")
$html | Out-File $filePath"\AADSyncInfo.html"
 
Remove-Variable html