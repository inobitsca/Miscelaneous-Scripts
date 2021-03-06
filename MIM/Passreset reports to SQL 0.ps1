<#
FIM Reports
Inobits Script
2016/08/11
version 2.0

Description:
-Number of users that used FIM to reset their own password
#>


#Set the FIM Service address
set-variable -name URI -value "http://localhost:5725/resourcemanagementservice' " -option constant

#Target output folder
$TARGETDIR = 'C:\Reports\CA\'

#write-host "Output folder is:" $TARGETDIR
#-----------Check if the Target Folder exists and create if needed.

if(!(Test-Path -Path $TARGETDIR))
{
    #write-host "Output folder does not exist, creating folder for the reports"
    New-Item -ItemType directory -Path $TARGETDIR
}

#Get todays date
$StartDate=""
$StartDate=(GET-DATE -format  yyyy-MM-dd-HH-mm-ss)
$FileDate=(GET-DATE -format  yyyy-MM-dd-HH-mm-ss)
$filename = "PasswordResetUsers " + $Filedate + ".csv"
$header = "Dispaly Name;UserAccountName";ResetDate
$outfile = $targetdir + $filename

#The export csv files
#set-variable -name PasswordResetUsers -value $filename -option constant


clear

#write-host "Check if the FIMAutomation Snapin is loaded. If no load it..."
If(@(Get-PSSnapin | Where-Object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {Add-PSSnapin FIMAutomation} 




#-----------Begin PasswordReset--------------------------
#write-host "Begin the report: Users that have used the Self-Service Password Reset Portal to reset their account"
        #Set some FIM Service objects
        #AnonymousUser ObjectID 
        $AnonymousUser = "b0b36673-d43b-4cfa-a7a2-aff14fd90522"


        #Select the correct MPR--------------------------
        # Default MPR for Anonymous users can reset their passwords
        # $AnonUsersCanResetPasswordMPR = "505e53d9-0f5e-4156-a722-a71621e02281"
        #$MPRFilter = "/ManagementPolicyRule[DisplayName='Anonymous users can reset their password']"
        #$curObjectMPR = export-fimconfig -uri $URI –onlyBaseResources -customconfig ($MPRFilter) -ErrorVariable Err -ErrorAction SilentlyContinue
        #$AnonUsersCanResetPasswordMPR = (($curObjectMPR.ResourceManagementObject.ResourceManagementAttributes | Where-Object {$_.AttributeName -eq "ObjectID"}).value).split(":")[2]

        # Custom MPR for Anonymous users can reset their passwords
        # $AnonUsersCanResetPasswordMPR = "d322d607-b367-459e-8dc3-215471c8ecae"

        $MPRFilter = "/ManagementPolicyRule[DisplayName='Password Reset: All Active Users Can Reset Password']"
        $curObjectMPR = export-fimconfig -uri $URI –onlyBaseResources -customconfig ($MPRFilter) -ErrorVariable Err -ErrorAction SilentlyContinue
        $AnonUsersCanResetPasswordMPR = (($curObjectMPR.ResourceManagementObject.ResourceManagementAttributes | Where-Object {$_.AttributeName -eq "ObjectID"}).value).split(":")[2]
                  
        #------Set the XPATH Filter for PasswordReset----------

        $filterPasswordReset = "/Request[" + "Creator='$AnonymousUser' and " + "ManagementPolicy = '$AnonUsersCanResetPasswordMPR' and " + "RequestStatus = 'Completed'" + "]"

        #This filter does not include the MPR Anonymous users can reset their passwords
        #$filterPasswordReset = "/Request[" + "Creator='$AnonymousUser' and " + "RequestStatus = 'Completed'" + "]"
        # -----Get all the objects that match the filter for PasswordReset


        $curObjectPasswordReset = export-fimconfig -uri $URI –onlyBaseResources -customconfig ($filterPasswordReset) -ErrorVariable Err -ErrorAction SilentlyContinue

        #write-host "Report only on users that have reset their passwords in the current month"

                foreach($Object in $curObjectPasswordReset) 
                {

                 #Get the CommittedTime of the PasswordReset
                 [DateTime]$CommittedTime = (($Object.ResourceManagementObject.ResourceManagementAttributes | Where-Object {$_.AttributeName -eq "CommittedTime"}).Value)
                 #Add +2Hours for localization
                 $CommittedTime = $CommittedTime.AddHours(2)
  
                     #If this CommittedTime is less than 30 days ago
                     #if ((New-TimeSpan -Start $StartDate -End $CommittedTime).Days -ge -30)


                   
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
                         $ResetPass = New-Object PSObject
                         $ResetPass | Add-Member NoteProperty "DisplayName" $UserDisplayName
                         $ResetPass | Add-Member NoteProperty "CommittedTime" $CommittedTime
                         $ResetPass | Add-Member NoteProperty "AccountName" $UserAccountName
                         $ResetPass | Add-Member NoteProperty "Target" $Target
 
                        #$UsersPasswordReset += $ResetPass
						$CT1 = $CommittedTime.addseconds(-($CommittedTime.second % 60))
						$Ct = get-date $CT1 -format yyyy-MM-ddTHH:mm:ss
			
						$out = $UserDisplayName  + ";" + $UserAccountName + ";" + $CT

				#Create SQL statement to check for an existing entry for each reset attempt                     
				$statement = "select * from Passresets where SAMAccountName = '" + $UserAccountName + "' and resettime = '" + $CT + "' "


                    
#######Start SQL Query for existing record and commit to SQL if it not present#######
$time = "x"
$conn = New-Object System.Data.SqlClient.SqlConnection
$conn.ConnectionString = "Data Source=dbFIMService;Initial Catalog=FIMLogging;Integrated Security=SSPI;"
$conn.open()
$cmd = New-Object System.Data.SqlClient.SqlCommand
$cmd.connection = $conn
$cmd.commandtext = $Statement
$output = ""
$reader = $cmd.ExecuteReader()

while ($reader.Read())
{ 
   $UID = $reader.GetValue(0);
   $SAM = $reader.GetValue(1);
   $dt = $reader.GetValue(2);
   $time1 = $dt.addseconds(-($dt.second % 60));
   $Time = get-Date $time1 -format  yyyy-MM-ddTHH:mm:ss;
   $output = $UID,$SAM,$Disp,$Firstname,$lastname,$time
}


$reader.Close()

###Start IF statement
#write-host $output

 if ($time -like "*00")
{
write-host "Existing Data Present - Not writing to SQL"
$conn.close()

}
else 
{
write-host "No Data: Committing to SQL" 
$out >> $outfile
$cmd = New-Object System.Data.SqlClient.SqlCommand
$cmd.connection = $conn

$cmd.commandtext = "INSERT INTO passresets(SamAccountname,ResetTime) VALUES('{0}','{1}')" -f $UserAccountName,$CT
$cmd.executenonquery()
$conn.close()
    
                  }
				  #########End SQL Query ############
}

       
#-----------End PasswordReset--------------------------


#write-host "All done!"