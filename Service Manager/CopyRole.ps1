# USAGE:.\CopyRole.ps1 -from SourceServer -to DestinationServer -role NameOfRoleToExport -newrole NameOfNewRole

param ($From, $To, $Role, $NewRole)

If (! $From) {Write-host "No source server specified.  Please specify source server and try again" -fore red -back black; exit}
If (! $to) {$to = $from; write-host No `"to`" server specified`; Assuming copying to source server $From.toupper() -fore yellow}

#Load SM PS module if not already loaded
If ( ! (Get-module System.Center.Service.Manager )) { Import-Module "$env:programfiles\Microsoft System Center 2012\Service Manager\Powershell\System.Center.Service.Manager.psd1" }

#Clear error variable for better error handling
$error.clear()

#Set error action preference to hidden to not confuse users and handle errors ourselves
$ErrorActionPreference = "SilentlyContinue"

#Get the specified user role or all if not specified
write-host Getting user role`(s`) from $From.toupper()
If ($Role)
{
	$AllUserRoles = get-scsmuserrole -displayname $Role -computer $From
} else 
{
	$AllUserRoles = get-scsmuserrole -computer $From
}

#Error if invalid SDK server specified
If ($error[0] -like "The Data Access service is either not running or not yet initialized*")
{
	write-host Invalid management server specified. Please verify the `"computer`" switch and try again. -fore red -back black; exit
}

#Set error action preference to continue in case we missed handling any errors
$ErrorActionPreference = "Continue"

If(! $Role)
{

$list = "Activity Implementers","Administrators","Advanced Operators","Authors","Change Initiators","Change Managers","End Users","Incident Resolvers","Problem Analysts","Read-Only Operators","Release Managers","Service Request Analysts","Workflows"

$Role = $alluserroles | where displayname -notin $list

} Else {
$Role = $alluserroles | where displayname -eq $Role
}

Foreach ($UserRole in $Role)
{

#Filter to specific role
#$UserRoleA = $AllUserRoles | where {$_.displayname -eq $UserRole}

#Get user role type
$Type = $UserRole.userrole.profile.name

#Getting the class
$class = $userrole | foreach {$_.classes}

#Getting the queue
$queue = $userrole | foreach {$_.queue}

#Getting the group
$group = $userrole | foreach {$_.group}

#Getting the catalog group
$cgroup = $userrole | foreach {$_.cataloggroup}

#Getting the tasks
$task = $userrole | foreach {$_.task}

#Getting the views
$view = $userrole | foreach {$_.view}

#Getting the template
$template = $userrole | foreach {$_.formtemplate}

#Getting the users
$user = $userrole | foreach {$_.user}

#Remove and create a new variable to store the newly created variable in
if ($UserRoleEnvB) {remove-variable UserRoleEnvB}
new-variable UserRoleEnvB

#Creating the shell user role
If (($List) -or (! $NewRole)) {$NewRole = $UserRole.DisplayName}
If (! $UserRole.Description)
{
write-host Creating user role $NewRole in $To.toupper() -fore green
new-scsmuserrole -userroletype $Type -computer $To -displayname $NewRole -passthru | set-variable UserRoleEnvB
} Else {

write-host Creating user role $NewRole in $To.toupper() -fore green
new-scsmuserrole -userroletype $Type -computer $To -displayname $NewRole -Description $UserRole.Description -passthru | set-variable UserRoleEnvB

}

#If not null, add each item to the user role
If ($class)
{$UserRoleEnvB | %{$_.classes = $class; $_} | update-scsmuserrole}
If ($queue)
{$UserRoleEnvB | %{$_.queue = $queue; $_} | update-scsmuserrole}
If ($group)
{$UserRoleEnvB | %{$_.group = $group; $_} | update-scsmuserrole}
If ($cgroup)
{$UserRoleEnvB | %{$_.cataloggroup = $cgroup; $_} | update-scsmuserrole}
If ($task)
{$UserRoleEnvB | %{$_.task = $task; $_} | update-scsmuserrole}
If ($view)
{$UserRoleEnvB | %{$_.view = $view; $_} | update-scsmuserrole}
If ($template)
{$UserRoleEnvB | %{$_.formtemplate = $template; $_} | update-scsmuserrole}
If ($user)
{$UserRoleEnvB | %{$_.user = $user; $_} | update-scsmuserrole}

}

#Add Backup
#Add Restore