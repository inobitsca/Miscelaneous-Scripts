param (
    $Username, 
    $Password
    )

BEGIN
{#Writing Start tag in Debug File.
$DebugFilePath = "D:\HomeFolder\DebugHomeFolderMA.txt"
    if(!(Test-Path $DebugFilePath))
    {$DebugFile = New-Item -Path $DebugFilePath -ItemType File}
    else
    {$DebugFile = Get-Item -Path $DebugFilePath}
"Starting Export : " + (Get-Date) | Out-File $DebugFile -Append
}

PROCESS
{
#Initialize Parameters
$Identifier = $_.Identifier
$objectGuid = $_.DN
$ErrorName = "success"
$ErrorDetail = $null
$date = Get-Date -Format "yyyy-MM-dd"

$curUser = New-Object System.DirectoryServices.DirectoryEntry "LDAP://<GUID=$objectGuid>", $Username, $Password
$curHomeDirectory = $curUser.homeDirectory.Value
$curHomeDrive = $curUser.homeDrive.Value
$account = $curUser.sAMAccountName.Value
$defaultDrive = "H:"

#Writing curUser to debug file
"$Identifier : " +$Identifier | Out-File $DebugFile -Append
"$objectGuid : " +$objectGuid | Out-File $DebugFile -Append
"$curHomeDirectory : " +$curHomeDirectory | Out-File $DebugFile -Append
"$curHomeDrive : " +$curHomeDrive | Out-File $DebugFile -Append
"$account : " +$account | Out-File $DebugFile -Append
"DN : " + $_.DN | Out-File $DebugFile -Append
"No of Changes : " + $_.ChangedAttributeNames.Count | Out-File $DebugFile -Append

### --- FUNCTIONS --- ###
#NOTE! Function calls from the script will generate output to the pipeline unless catched by parameter.
#This output will be seen as errors when running the MA
#Call functions using $catch = FunctionName param1 param2

#Function for adding AccessRule to folder
#$A = Account in the format "AccountName"
#$F = Folder
#$P = Permission to assign. Modify, Read or FullControl typically
#Inheritence is added by default.
function AddAccessRule($F, $A, $P)
    {
    Try{
        $acl = Get-Acl $F
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($A,$P,"ContainerInherit,ObjectInherit","None","Allow")
        $acl.AddAccessRule($rule)
        Set-Acl -Path $F.FullName -AclObject $acl
        }
    Catch
        {
        "Error in AddAccessRule" | Out-File $DebugFile -Append
        $ErrorName = "Script Error"
        $ErrorDetail = "Error when trying to Add Access Rule"
        }
    }

#Function for adding default subfolders to new homefolders
#F = Folder where subfolders should be created
function AddDefaultFolders($F)
    {
    #If you are running Notes for example might like to have this
    #New-Item $F"\Program\Lotus\Notes\Data" -Type Directory
    }


#Function for setting homeDirectory and homeDrive attribute on user in AD
#Dir = Full homeDirectory path in the format \\server\share\username
#Drive = The drive letter to use, H:
function UpdateUser($Dir,$Drive)
    {
    If($Dir)
        {
        $curUser.homeDirectory.Value = $Dir
        if($Drive){$curUser.homeDrive.Value = $Drive}else{$curUser.homeDrive.Value = $defaultDrive}
        }
    else
        {
        $curUser.homeDirectory.Value = $null
        $curUser.homeDrive.Value = $null
        }
    $curUser.SetInfo()
    }

### --- End of FUNCTIONS --- ###



### --- MAIN SCRIPT --- ###

#Loop through changes and update parameters
foreach ($can in $_.ChangedAttributeNames)
    {# $can : ChangedAttributeName
    foreach ($ValueChange in $_.AttributeChanges[$can].ValueChanges)
        {
        if ( $can -eq 'homeFolderPath' ){$homeFolderPath = $ValueChange.Value}
        }
    }

#Verify changetype.
if ($_.ObjectModificationType -eq 'Add')
	{
    # adds are caught by importing new objects from Active Directory (see import script)
	# and joining these to existing user objects on the metaverse
	throw "Add modification are not supported"
	}
	
if ($_.ObjectModificationType -eq 'Delete')
	{
    # deletes are caught by importing deleted objects (isDeleted) from Active 
	# Directory (see import script). This way we clear up the CS
	throw "Delete modification are not supported"
	}

#Supported ChangeType is Replace
if ($_.ObjectModificationType -match 'Replace')
	{
    #Three scenarios
    # 1. No current HomeDir -> Get new HomeDir : NewHomeDir
    # 2. Current HomeDir -> New homedir : MoveHomeDir
    # 3. Current HomeDir -> No homedir : DeleteHomeDir
    
    # 1. No current HomeDir -> Get new HomeDir : NewHomeDir
    if(-not($curHomeDirectory) -and $homeFolderPath)
        {#NewHomeDir
        #Check if folder already Exists
        $exists = Test-Path $homeFolderPath
        if(!$exists)
            {
            #Check if Deleted or Moved folder Exists
            $parent = Get-Item $homeFolderPath.Substring(0,$homeFolderPath.LastIndexOf("\"))
            $existingFolder = Get-ChildItem $parent -Filter *$account
            if(!$existingFolder)
                {#Create NEW HomeFolder
                "Creating new homefolder at " + $homeFolderPath + " for : $account" | Out-File $DebugFile -Append
                $folder = New-Item $homeFolderPath -Type Directory
                $catch = AddAccessRule $folder $account "Modify"
                $catch = AddDefaultFolders $folder
                $catch = UpdateUser $homeFolderPath $defaultDrive
                }
            else
                {#Existing Folder already in place.
                #Folder can be Deleted or Moved
                If($existingFolder.Name.StartsWith("Deleted_"))
                    {#Folder is marked Deleted
                    "Un-deleting homefolder for : $account" | Out-File $DebugFile -Append
                    #Rename Existing Folder to activate it again.
                    Rename-Item (Get-Item $existingFolder.FullName) $account
                    
                    #Add AccessRule just in case it is missing.
                    $folder = Get-Item $homeFolderPath
                    $catch = AddAccessRule $folder $account "Modify"
                    $catch = UpdateUser $homeFolderPath $defaultDrive
                    }
                else
                    {#Folder is likely Moved. More control can be added later if required to detect anomalies.
                    $ErrorName = "Conflicting Folder"
                    $ErrorDetail = "Moved folder might already exist in homeFolderPath"
                    }
                }
            }
        else
            {
            #Folder already exists!
            #Likely a missmatch in AD and Folder data. Update user and folder
            "Found Existing folder, adding access rule and updating user" | Out-File $DebugFile -Append
            $folder = Get-Item $homeFolderPath
            $catch = AddAccessRule $folder $account "Modify"
            $catch = UpdateUser $homeFolderPath $defaultDrive
            }
        }
    
    # 2. Current HomeDir -> New homedir : MoveHomeDir
    if($curHomeDirectory -and $homeFolderPath)
        {#MoveHomeDir or difference in typing
        if($curHomeDirectory -eq $homeFolderPath)
            {#A difference in typing maybe update the AD user
            "No Change in folders, Updating user" | Out-File $DebugFile -Append
            $catch = UpdateUser $homeFolderPath $defaultDrive
            }
        else
            {#New Path. Copy folder and rename old path
            "Moving homefolder, $curHomeDirectory, for $account to $homeFolderPath" | Out-File $DebugFile -Append
            Copy-Item -Path $curHomeDirectory -Destination $homeFolderPath -Recurse
            $folder = Get-Item $homeFolderPath
            $catch = AddAccessRule $folder $account "Modify"
            $MovedName = "Moved_" + $date + "_" + $account
            Rename-Item $curHomeDirectory $MovedName
            #Update User
            $catch = UpdateUser $homeFolderPath $defaultDrive
            }
        }
    
    # 3. Current HomeDir -> No homedir : DeleteHomeDir    
    if($curHomeDirectory -and !$homeFolderPath)
        {#Delete HomeDirectory. Renaming the folder. We are not actually deleting the folders.
        "Deleting homefolder for $account" | Out-File $DebugFile -Append
        $DeletedName = "Deleted_" + $date + "_" + $account
        Rename-Item $curHomeDirectory $DeletedName
        #Update User
        $catch = UpdateUser $null $null
        }
    }

#Return the result to the MA
$obj = @{}
$obj.Add("[Identifier]",$Identifier)
$obj.Add("[ErrorName]",$ErrorName)
if($ErrorDetail){$obj.Add("[ErrorDetail]",$ErrorDetail)}
$obj
}

END
{#Writing close tag in debugfile
"Ending Export : " + (Get-Date) | Out-File $DebugFile -Append
}
