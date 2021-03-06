# Import MCS-FIM-Cmdlets module for PowerShell commandlets
write-host -ForegroundColor Cyan "Beginning Step 1 of Configuring the FIM Service"
Import-Module .\MCS-FIM-Cmdlets.dll

# Update Existing MPR's
write-host -ForegroundColor Cyan "Updating Default FIM MPRs"
Set-FIMMPR "Administration - Schema: Administrators can change selected attributes of schema related resources" -Disable
Set-FIMMPR "Administration - Schema: Administrators can delete non-system schema related resources" -AddActionParameters *
Set-FIMMPR "Administration: Administrators can read and update Users" -AddActionParameters *
Set-FIMMPR "Administration: Administrators control configuration related resources" -AddActionParameters *
Set-FIMMPR "Administration: Administrators control set resources" -AddActionParameters *
Set-FIMMPR "General: Users can read non-administrative configuration resources" -Enable
Set-FIMMPR "Group management workflow: Owner approval on add member" -Disable
Set-FIMMPR "Group management: Group administrators can create and delete group resources" -Enable
Set-FIMMPR "Group management: Group administrators can update group resources" -AddActionParameters *
Set-FIMMPR "Security group management: Owners can update and delete groups they own" -AddActionParameters * -Enable
Set-FIMMPR "Security Group management: Users can create Static Security Groups" -AddActionParameters *
Set-FIMMPR "Synchronization: Synchronization account can read group resources it synchronizes" -AddActionParameters * -Enable
Set-FIMMPR "Synchronization: Synchronization account controls group resources it synchronizes" -AddActionParameters * -Enable
Set-FIMMPR "Synchronization: Synchronization account controls users it synchronizes" -AddActionParameters *
Set-FIMMPR "User management: Users can read attributes of their own" -Enable
Set-FIMMPR "User management: Users can read selected attributes of other users" -Enable
Set-FIMMPR "Group management workflow: Validate requestor on add member to open group" -Disable

# Add a new Administrative MPR
# First we have to get the object ID of the administrators and all set objects Sets
write-host -ForegroundColor Cyan "Adding New FIM Administrators Set"
$administratorsSetObjectID = Get-FIMSet "Administrators" -ObjectIDOnly
$allSchemaObjectsSetObjectID = Get-FIMSet "All Schema Objects" -ObjectIDOnly
Add-FIMMPR "Administration - Schema: Administrators can change all attributes of schema related resources" -Description "Administrators have full access to schema related resources." -ActionType Modify -GrantRight $True -ActionParameter * -MPRType Request -PrincipalSet $administratorsSetObjectID -ResourceCurrentSet $allSchemaObjectsSetObjectID -ResourceFinalSet $allSchemaObjectsSetObjectID

# Add and Update Schema Attributes and Bindings to FIM
write-host -ForegroundColor Cyan "Adding FIM Schema Attributes and Bindings"
$attributes = Import-CSV FIMSchemaUpdates-GroupMgmt.csv;
$bindings = Import-CSV FIMBindingUpdates-GroupMgmt.csv;

foreach ($attribute in $attributes)
{
    $attrSysName = $attribute.SystemName;
    $attrDisplayName = $attribute.DisplayName;
    $attrDescription = $attribute.Description;
    $attrDataType = $attribute.DataType;
    $attrMultiVal = $attribute.MultiValued;
        
    Add-FIMSchemaAttribute -Name $attrSysName -DisplayName $attrDisplayName -DataType $attrDataType -Multivalued $attrMultiVal -Description $attrDescription;
}

foreach ($binding in $bindings)
{
    $bindObjectType = $binding.objectType;
    $bindAttributeType = $binding.attributeType;
    $bindRequired = $binding.required;
        
    Add-FimSchemaBinding -ObjectType $bindObjectType -AttributeType $bindAttributeType -Required $bindRequired
}

Set-FIMSchemaBinding -DisplayName "Membership Add Workflow" -StringRegEx "^(None|Custom|Owner Approval|Owner Managed)?$"

# Set FIM Filter Permissions
write-host -ForegroundColor Cyan "Updating FIM Filter Permissions"
Set-FIMFilterScope "Administrator Filter Permission" -AddAllowedAttributes GoodbyeMessageEnabled, WelcomeMessageEnabled

# Configure FIM RCDCs
write-host -ForegroundColor Cyan "Configuring FIM RCDCs"
Set-FIMRCDC "Configuration for User Editing" -ConfigFile RCDC-UserUpdate.xml
Set-FIMRCDC "Configuration for User Viewing" -ConfigFile RCDC-UserRead.xml
Set-FIMRCDC "Configuration for User Creation" -ConfigFile RCDC-UserCreate.xml
Set-FIMRCDC "Configuration for Group Editing" -ConfigFile RCDC-GroupUpdate.xml
Set-FIMRCDC "Configuration for Group Viewing" -ConfigFile RCDC-GroupRead.xml
Set-FIMRCDC "Configuration for Group Creation" -ConfigFile RCDC-GroupCreate.xml

# Add Email Templates to FIM
write-host -ForegroundColor Cyan "Adding FIM Email Templates"
Add-FIMEmailTemplate "Notification: Goodbye from Group Email" -EmailSubject "You have been removed from the [//Target/DisplayName] Group" -EmailBodyFile EmailTemplate-GoodbyeFromGroup.html -EmailType "Notification"
Add-FIMEmailTemplate "Notification: Welcome to Group Email" -EmailSubject "You have been added to the [//Target/DisplayName] Group" -EmailBodyFile EmailTemplate-WelcomeToGroup.html -EmailType "Notification"

# Update existing FIM Sets
write-host -ForegroundColor Cyan "Updating Existing FIM Sets"
Set-FIMSet "Open Groups" -Description "This set contains all groups which are open for anyone to join them." -Filter "/Group[(MembershipLocked=false) and (MembershipAddWorkflow='None')]"
Set-FIMSet "Open Security Groups" -Description "This set contains all security groups which are open for anyone to join them." -Filter "/Group[(MembershipLocked=false) and (MembershipAddWorkflow='None') and (Type='Security' or Type='MailenabledSecurity')]"
Set-FIMSet "Owner Approved Groups" -Description "This set contains all groups which are subject to owners approval." -Filter "/Group[MembershipAddWorkflow='Owner Approval']"
Set-FIMSet "Owner Approved Security Groups" -Description "This set contains all security groups which are subject to owners approval." -Filter "/Group[(MembershipAddWorkflow='Owner Approval') and (Type='Security' or Type='MailenabledSecurity')]"
Set-FIMSet "All Non-Administrators" -Description "This set contains all users who are not a part of the default administrators set." -Filter "/Person[ObjectID != /Set[ObjectID = '10000005-1111-45b5-ad13-2764d866c000']/ComputedMember]"

# Add FIM Sets
write-host -ForegroundColor Cyan "Adding FIM Sets"
Add-FIMSet "All Groups with Goodbye Messages Configured" -Description "This set contains all groups which have been enabled for sending goodbye email messages." -Filter "/Group[GoodbyeMessageEnabled = True]"
Add-FIMSet "All Groups with Welcome Messages Configured" -Description "This set contains all groups that have been enabled to send welcome email messages." -Filter "/Group[WelcomeMessageEnabled = True]"

# Perform an IIS reset
IISRESET

# Stop and start the FIM Service
net stop fimservice
net start fimservice

write-host -ForegroundColor Yellow "--Step 1 of configuring the FIM Service is Complete--"
write-host -ForegroundColor Yellow "You must now configure the FIM Synchronization Service before continuing!"