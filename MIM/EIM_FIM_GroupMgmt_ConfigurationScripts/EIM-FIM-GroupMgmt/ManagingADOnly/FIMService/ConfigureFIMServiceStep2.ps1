# Step 2 in configuring the FIM Service
write-host -ForegroundColor Red "Do not run this step until you have completed the configuration of the FIM Synchronization Service!"
Write-Host "Press any key to continue  or CTRL+C to quit..."

$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")

# Import MCS-FIM-Cmdlets module for PowerShell commandlets
write-host -ForegroundColor Cyan "Beginning Step 2 of Configuring the FIM Service"
Import-Module .\MCS-FIM-Cmdlets.dll

# Add FIM Synchronization Rules
write-host -ForegroundColor Cyan "Adding FIM Synchronization Rules"
Add-FIMSyncRule "AD DS: Users (Inbound)" -ConfigFile SyncRule-ADDSUsersInbound.txt
Add-FIMSyncRule "AD DS: Groups (Inbound)" -ConfigFile SyncRule-ADDSGroupsInbound.txt
Add-FIMSyncRule "AD DS: Groups (Outbound)" -ConfigFile SyncRule-ADDSGroupsOutbound.txt

# Add FIM Workflow Activities
write-host -ForegroundColor Cyan "Adding FIM Workflow Activities"
Add-FIMWorkflow "Synchronization: Add AD DS Groups (Outbound Sync Rule)" -RequestPhase Action -ConfigFile WF-SyncAddADDSGroupsOutbound.xml
$sync_rule_id = Get-FIMSyncRule "AD DS: Groups (Outbound)" -ObjectIDOnly
Set-FIMWorkflow "Synchronization: Add AD DS Groups (Outbound Sync Rule)" -ActivityName authenticationGateActivity1 -SyncRuleID $sync_rule_id

Add-FIMWorkflow "Notification: Welcome to Group Email" -RequestPhase Action -ConfigFile WF-NotificationWelcomeToGroupEmail.xml
$welcome_email_template_id = Get-FIMEmailTemplate "Notification: Welcome to Group Email" -ObjectIDOnly
Set-FIMWorkflow "Notification: Welcome to Group Email" -ActivityName authenticationGateActivity1 -EmailTemplate $welcome_email_template_id

Add-FIMWorkflow "Notification: Goodbye from Group Email" -RequestPhase Action -ConfigFile WF-NotificationGoodbyeFromGroupEmail.xml
$goodbye_email_template_id = Get-FIMEmailTemplate "Notification: Goodbye from Group Email" -ObjectIDOnly
Set-FIMWorkflow "Notification: Goodbye from Group Email" -ActivityName authenticationGateActivity1 -EmailTemplate $goodbye_email_template_id

# ADD FIM MPRs
write-host -ForegroundColor Cyan "Adding FIM Management Policy Rules"
$allActivePeopleSetObjectID = Get-FIMSet "All Active People" -ObjectIDOnly
$allPeopleSetObjectID = Get-FIMSet "All People" -ObjectIDOnly
$allSecurityGroupsSetObjectID = Get-FIMSet "All Security Groups" -ObjectIDOnly
$allSecurityGroupsNotHidden = Get-FIMSet "All Security Groups That are not Hidden from Address Lists" -ObjectIDOnly
$openSecurityGroupsSetObjectID = Get-FIMSet "Open Security Groups" -ObjectIDOnly
$allSecGroupsNotConfigToHideMemb = Get-FIMSet "All Security Groups Not Configured to Hide Membership" -ObjectIDOnly
$ownerApprovedSecurityGroupsSetObjectID = Get-FIMSet "Owner Approved Security Groups" -ObjectIDOnly
$allGrpsWithGbyeMessConfSetObjectID = Get-FIMSet "All Groups with Goodbye Messages Configured" -ObjectIDOnly
$allGrpsWithWelcMessConfSetObjectID = Get-FIMSet "All Groups with Welcome Messages Configured" -ObjectIDOnly
$allGroupsSetObjectID = Get-FIMSet "All Groups" -ObjectIDOnly
$administratorsSetObjectID = Get-FIMSet "Administrators" -ObjectIDOnly
$ownerApprovedGroupsSetObjectID = Get-FIMSet "Owner Approved Groups" -ObjectIDOnly
$ownerApprovedSecGroupsSetObjectID = Get-FIMSet "Owner Approved Security Groups" -ObjectIDOnly
$allNonAdminsSetObjectID = Get-FIMSet "All Non-Administrators" -ObjectIDOnly
$ownerApprovalWFDSetObjectID = Get-FIMWorkflow "Owner Approval Workflow" -ObjectIDOnly
$welcomeGroupEmailWFDSetObjectID = Get-FIMWorkflow "Notification: Welcome to Group Email" -ObjectIDOnly
$goodByeGroupEmailWFDSetObjectID = Get-FIMWorkflow "Notification: Goodbye from Group Email" -ObjectIDOnly
$addADDSGroupsOBSRWFDSetObjectID = Get-FIMWorkflow "Synchronization: Add AD DS Groups (Outbound Sync Rule)" -ObjectIDOnly
$reqValidWithoutOwnerAuthN = Get-FIMWorkflow "Requestor Validation Without Owner Authorization" -ObjectIDOnly
$ownerAttrTypeDescObjectID = Get-FIMAttributeTypeDescription "Owner" -ObjectIDOnly

Add-FIMMPR "Administration: Administrators can read and update Groups" -ActionType Add, Create, Modify, Remove -ActionParameter * -MPRType Request -PrincipalSet $administratorsSetObjectID -ResourceCurrentSet $allGroupsSetObjectID -ResourceFinalSet $allGroupsSetObjectID
Add-FIMMPR "Group Management Workflow: Validate requestor on add member to Owner Approved Groups" -ActionType Add -ActionParameters ExplicitMember -MPRType Request -AuthorizationWorkflowDefinition $reqValidWithoutOwnerAuthN -PrincipalSet $allNonAdminsSetObjectID -ResourceCurrentSet $ownerApprovedGroupsSetObjectID -ResourceFinalSet $ownerApprovedGroupsSetObjectID
Add-FIMMPR "Security Group Management: All Active People can create Static Security Groups" -ActionType Create -ActionParameters * -MPRType Request -PrincipalSet $allActivePeopleSetObjectID -ResourceFinalSet $allSecurityGroupsSetObjectID
Add-FIMMPR "Security Group Management: All Active People can add or remove any member of groups subject to owner approval" -ActionType Add, Remove -ActionParameters ExplicitMember -MPRType Request -AuthorizationWorkflowDefinition $ownerApprovalWFDSetObjectID -PrincipalSet $allActivePeopleSetObjectID -ResourceCurrentSet $ownerApprovedSecurityGroupsSetObjectID -ResourceFinalSet $ownerApprovedSecurityGroupsSetObjectID
Add-FIMMPR "Security Group Management: Users can add or remove any members of security groups that do not require owner approval" -ActionType Add, Read, Remove -ActionParameters ExplicitMember -MPRType Request -GrantRight $True -PrincipalSet $allActivePeopleSetObjectID -ResourceCurrentSet $openSecurityGroupsSetObjectID -ResourceFinalSet $openSecurityGroupsSetObjectID
Add-FIMMPR "Security Group Management: All active people can read selected attributes of security group resources" -ActionType Read -ActionParameter AccountName, Description, DisplayedOwner, DisplayName, Domain, Email, MailNickname, MembershipLocked, Owner, Scope, Type, GoodbyeMessage, GoodbyeMessageEnabled, WelcomeMessage, WelcomeMessageEnabled, ComputedMember, DomainConfiguration, Locale, MembershipAddWorkflow, ObjectID, ObjectType -MPRType Request -PrincipalSet $allActivePeopleSetObjectID -ResourceCurrentSet $allSecurityGroupsNotHidden
Add-FIMMPR "Security Group Management: Owners can read attributes of Security Groups" -ActionType Read -ActionParameter * -MPRType Request -PrincipalRelativeToResource Owner -ResourceCurrentSet $allSecurityGroupsSetObjectID
Add-FIMMPR "Security Group Management: All Active People Can Read Member for Groups Not Hidden" -Description "This MPR allows all active people the ability to read the member attribute for security groups which have not been configured for hidden membership." -ActionType Read -MPRType Request -Enabled -ActionParameters ExplicitMember -PrincipalSet $allActivePeopleSetObjectID -ResourceCurrentSet $allSecGroupsNotConfigToHideMemb
Add-FIMMPR "Notification: Send Goodbye Message for Users Removed from Groups" -Description "This MPR is triggered when a user is removed as an explicit member of a group. Once a user is removed, an email notification is sent letting them know they have been removed from the group." -ActionType Remove -ActionParameter ExplicitMember -GrantRight $False -MPRType Request -ActionWorkflowDefinition $goodByeGroupEmailWFDSetObjectID -PrincipalSet $allPeopleSetObjectID -ResourceCurrentSet $allGrpsWithGbyeMessConfSetObjectID -ResourceFinalSet $allGrpsWithGbyeMessConfSetObjectID
Add-FIMMPR "Notification: Send Welcome Message for Users Added to Groups" -Description "This MPR is triggered when a new user is added as an explicit member of a group. Once a user is added, an email notification is sent welcoming them to the group." -ActionType Add -ActionParameter ExplicitMember -GrantRight $False -MPRType Request -ActionWorkflowDefinition $welcomeGroupEmailWFDSetObjectID -PrincipalSet $allPeopleSetObjectID -ResourceCurrentSet $allGrpsWithWelcMessConfSetObjectID -ResourceFinalSet $allGrpsWithWelcMessConfSetObjectID
Add-FIMMPR "Synchronization: Add AD DS Groups (Outbound Sync) Synchronization Rule to Groups" -ActionType TransitionIn -GrantRight $False -MPRType SetTransition -ActionWorkflowDefinition $addADDSGroupsOBSRWFDSetObjectID -ResourceFinalSet $allGroupsSetObjectID

# Configure FIM Home Page Resources
write-host -ForegroundColor Cyan "Changing FIM Home Page Resources"
Set-FIMHomepageConfig -Name "Security Groups (SGs)" -AddUsageKeyword "BasicUI"
Set-FIMHomepageConfig -Name "Manage my SGs" -AddUsageKeyword "BasicUI"
Set-FIMHomepageConfig -Name "See my SG memberships" -AddUsageKeyword "BasicUI"
Set-FIMHomepageConfig -Name "Join a SG" -AddUsageKeyword "BasicUI"
Set-FIMHomepageConfig -Name "Create a new SG" -AddUsageKeyword "BasicUI"

# Configure FIM Navigation Bar Resources
write-host -ForegroundColor Cyan "Changing FIM Navigation Bar Resources"
Set-FIMNavBarResource -Name "Security Groups (SGs)" -AddUsageKeyword "BasicUI"
Set-FIMNavBarResource -Name "My SGs" -AddUsageKeyword "BasicUI"
Set-FIMNavBarResource -Name "My SG Memberships" -AddUsageKeyword "BasicUI"

# Perform an IIS reset
IISRESET

# Stop and start the FIM Service
net stop fimservice
net start fimservice

write-host -ForegroundColor Yellow "You have now finished configuring the FIM Service configuration."
write-host -ForegroundColor Yellow "Troubleshoot any errors."
write-host -ForegroundColor Yellow "If you did not receive errors you may continue onto the prepoulation process."