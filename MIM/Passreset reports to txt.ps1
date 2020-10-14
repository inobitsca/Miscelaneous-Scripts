<#
FIM Reports
Inobits Script
2018/06/26
version 2.0

Description:
-Number of users that used FIM to reset their own password
#>
#Set the FIM Service address
set-variable -name URI -value "http://localhost:5725/resourcemanagementservice' " -option constant
#Target output folder
$TARGETDIR = 'C:\Reports\CA\'
#Testing if folder exists, if not create it
if(!(Test-Path -Path $TARGETDIR))
{
    New-Item -ItemType directory -Path $TARGETDIR
}
#Get todays date
$StartDate=""
$StartDate=(GET-DATE -format  yyyy-MM-dd-HH-mm-ss)
$FileDate=(GET-DATE -format  yyyy-MM-dd-HH-mm-ss)
$filename = "PasswordResetUsers " + $Filedate + ".csv"
$header = "Dispaly Name;UserAccountName;ResetDate;Status"
$outfile = $targetdir + $filename
$header >> $Outfile
#Check if the FIMAutomation Snapin is loaded. If no load it.
If(@(Get-PSSnapin | Where-Object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {Add-PSSnapin FIMAutomation} 
#-----------Begin PasswordReset Report--------------------------
        #Set some FIM Service objects
        #AnonymousUser ObjectID 
        $AnonymousUser = "b0b36673-d43b-4cfa-a7a2-aff14fd90522"
        # Default MPR for Anonymous users can reset their passwords
        $AnonUsersCanResetPasswordMPR = "505e53d9-0f5e-4156-a722-a71621e02281"
        #----------------------------------------------
        #-------Alternative methods to find the correct MPR if you are using others
        #----------------------------------------------
        #$MPRFilter = "/ManagementPolicyRule[DisplayName='Anonymous users can reset their password']"
        #$curObjectMPR = export-fimconfig -uri $URI –onlyBaseResources -customconfig ($MPRFilter) -ErrorVariable Err -ErrorAction SilentlyContinue
        #$AnonUsersCanResetPasswordMPR = (($curObjectMPR.ResourceManagementObject.ResourceManagementAttributes | Where-Object {$_.AttributeName -eq "ObjectID"}).value).split(":")[2]
        #----------------------------------------------
        # Custom MPR for Anonymous users can reset their passwords
        # $AnonUsersCanResetPasswordMPR = "d322d607-b367-459e-8dc3-215471c8ecae"
        #----------------------------------------------
        #------Set the XPATH Filter for PasswordReset----------
        # $filterPasswordReset = "/Request[" + "Creator='$AnonymousUser' and "   + "RequestStatus = 'Completed'" + " and " + "ManagementPolicy = '$AnonUsersCanResetPasswordMPR']" 
        $filterPasswordReset = "/Request[" + "Creator='$AnonymousUser' and " + "ManagementPolicy = '$AnonUsersCanResetPasswordMPR']" 
        #This filter does not include the MPR Anonymous users can reset their passwords
        #$filterPasswordReset = "/Request[" + "Creator='$AnonymousUser' and " + "RequestStatus = 'PostProcessingError'" + "]"
        # -----Get all the objects that match the filter for PasswordReset
        $curObjectPasswordReset = export-fimconfig -uri $URI –onlyBaseResources -customconfig ($filterPasswordReset) -ErrorVariable Err -ErrorAction SilentlyContinue

        #write-host "Report only on users that have reset their passwords in the current month"

                foreach($Object in $curObjectPasswordReset) 
                {

                 #-------------Get the CommittedTime of the PasswordReset --------------
                [DateTime]$CommittedTime = (($Object.ResourceManagementObject.ResourceManagementAttributes | Where-Object {$_.AttributeName -eq "CommittedTime"}).Value)
                 #Add +2Hours for localization
                 $CommittedTime = $CommittedTime.AddHours(2)
                 $Status =   (($Object.ResourceManagementObject.ResourceManagementAttributes | Where-Object {$_.AttributeName -eq "RequestStatus"}).Value)
                 #----------------------------------------------
                 #If this CommittedTime is less than 30 days ago
                 #if ((New-TimeSpan -Start $StartDate -End $CommittedTime).Days -ge -30)
                 #----------------------------------------------
                 #Set the DisplayName Value
                         $UserDisplayName = (($Object.ResourceManagementObject.ResourceManagementAttributes | Where-Object {$_.AttributeName -eq "DisplayName"}).Value)
                         #Cleanup the DisplayName
                         $UserDisplayName = $UserDisplayName.Replace("Update to Person:","")
                         $UserDisplayName = $UserDisplayName.Replace("Request","")
                         $UserDisplayName = $UserDisplayName.Replace("'","")
                         $UserDisplayName = ($UserDisplayName).trim()
                         #Use the Target ObjectId to lookup the AccountName value
                         $Target = (($Object.ResourceManagementObject.ResourceManagementAttributes | Where-Object {$_.AttributeName -eq "Target"}).Value)
                         #Cleanup the Target value
                         $Target = $Target.Replace("urn:uuid:","")
                         #Look up the AccountName
                         $FilterTarget = "/Person[ObjectID='$Target']"
                         $LookupPerson = export-fimconfig -uri $URI –onlyBaseResources -customconfig ($FilterTarget) -ErrorVariable Err -ErrorAction SilentlyContinue
                         $UserAccountName = (($LookupPerson.ResourceManagementObject.ResourceManagementAttributes | Where-Object {$_.AttributeName -eq "AccountName"}).Value)
                         #Create new object
                         #$ResetPass = New-Object PSObject
                         #$ResetPass | Add-Member NoteProperty "DisplayName" $UserDisplayName
                         #$ResetPass | Add-Member NoteProperty "CommittedTime" $CommittedTime
                         #$ResetPass | Add-Member NoteProperty "AccountName" $UserAccountName
                         #$ResetPass | Add-Member NoteProperty "Target" $Target
 
                        #$UsersPasswordReset += $ResetPass
						$CT1 = $CommittedTime.addseconds(-($CommittedTime.second % 60))
						$Ct = get-date $CT1 -format yyyy-MM-ddTHH:mm:ss
			            $Ct = $Ct -replace "T" , " "
						$out = $UserDisplayName  + ";" + $UserAccountName +";" + $Ct + ";" + $Status

				$out >> $outfile

       }
#-----------End PasswordReset--------------------------


#write-host "All done!"