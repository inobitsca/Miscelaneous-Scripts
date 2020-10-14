#########################################################
#
# Name: FIMRoutineRunProcess.ps1
# Version: 1.0
# Date: 03/22/2012
# Comment: Script to execute FIM run profiles for the
#          EIM Using FIM for Group Management SIAM
#          Offering. 
#########################################################

############
# PARAMETERS
############
$params_ComputerName = "."  # "." is the current computer
$params_delayBetweenExecs = 30 #delay between each execution, in seconds
$params_numOfExecs = 0    #Number of executions 0 for infinite
$params_runProfilesOrder = 
@(
 @{
 name="FIM Service MA";
 profilesToRun=@("FIFS");
 };
 @{
 name="ADDS MA";
 profilesToRun=@("Export";"FIFS");
 };
 @{
 name="FIM Service MA";
 profilesToRun=@("EDI");
 };
);

############
# FUNCTIONS
############
$line = "-----------------------------"
function Write-Output-Banner([string]$msg) {
 Write-Output $line,$msg,$line
}

############
# DATAS
############

$MAs = @(get-wmiobject -class "MIIS_ManagementAgent" -namespace "root\MicrosoftIdentityIntegrationServer" -computername $params_ComputerName)
$numOfExecDone = 0

############
# PROGRAM
############
#do { # --Remove the comment if you want to run this in demo mode.
 Write-Output-Banner("Execution #:"+(++$numOfExecDone))
 foreach($MATypeNRun in $params_runProfilesOrder) {
 $found = $false;
 foreach($MA in $MAS) { 
 
   if(!$found) {
#  if($MA.Type.Equals($MATypeNRun.type)) {
  if($MA.Name.Equals($MATypeNRun.name)) {
  $found=$true;
  Write-Output-Banner("- MA Name: "+$MA.Name,"`n- Type: "+$MA.Type)
#  Write-Output-Banner("MA Type: "+$MA.Type)
  foreach($profileName in $MATypeNRun.profilesToRun) {
   Write-Output (" "+$profileName)," -> starting"
   $datetimeBefore = Get-Date;
   $result = $MA.Execute($profileName);
   $datetimeAfter = Get-Date;
   $duration = $datetimeAfter - $datetimeBefore;
   if("success".Equals($result.ReturnValue)){
   $msg = "done. Duration: "+$duration.Hours+":"+$duration.Minutes+":"+$duration.Seconds
   } else { 
   $msg = "Error: "+$result 
#   # Write the RunHistory file XML out to a file to then attach to the e-mail, and also set it to a XML attribute.
#   $RunHistory[1].RunDetails().ReturnValue | Out-File RunHistory.xml 

#   Grab the first run-history, which always is the latest result.
#   [xml]$RunHistoryXML = $RunHistory[1].RunDetails().ReturnValue
   #Take the MA RunDetails RunHistory XML and write to file.
#   $MA.RunDetails().ReturnValue | Out-File RunHistory.xml
   # Grab the MA run-history and put it into a XML var.
   [xml]$RunHistoryXML = $MA.RunDetails().ReturnValue
   # Build User Errors for Exports
   $RunHistoryXML."run-history"."run-details"."step-details"."synchronization-errors"."export-error" | select dn,"error-type" | export-csv ErrorUsers.csv
   }
   Write-Output (" -> "+$msg)
   Write-Output (" -> "+$result.ReturnValue)
  }
  }
   }
 }
 if(!$found) { Write-Output ("Not found MA type :"+$MATypeNRun.type); }
 }
 
 # use the following if you want to have the run processes execute every 30 seconds.
 # this is typically used for demonstrations so you do not have to wait for syncs to happen.
 # Uncomment the following 4 lines for demo mode.
 #$continue = ($params_numOfExecs -EQ 0) -OR ($numOfExecDone -lt $params_numOfExecs)
 #if($continue) { 
 #Write-Output-Banner("Sleeping "+$params_delayBetweenExecs+" seconds")
 #Start-Sleep -s $params_delayBetweenExecs
 
 #} -- remove for demo mode
#} while($continue) #remove 