CD C:\Scripts
Import-Module ActiveDirectory
cls
cd c:\scripts
### Update deparment list from SQL
###------------------------------------------------
c:\Windows\SQLCMD\sqlcmd -S DBSERVER -d DBNAME -E -Q "SELECT OUName,ParentName FROM Table" -o "Dept.csv" -W -w 1024 -s ","
Write-host ""
Write-host "                 Updating Department Data" -fore Green
Write-host "                 _________________________"
Write-host ""
Sleep -s 5
$DEPTS = Import-Csv C:\scripts\Dept.csv

### Set the root OU for the environment
###------------------------------------------------
##$RootOU = "OU=Users,OU=COMPANY,DC=DOMAIN,DC=COM" ### Production OU
$RootOU = "OU=Users,OU=TEST,DC=DOMAIN,DC=COM" ### Test OU
$count = 1
$restartCheck  = 0

### Process each department in the heierarchy 
###------------------------------------------------
foreach ($dept in $depts) 
{
$Name = $Dept.name
$Name = $Name -replace "&" , "and" # Replace APERSAND in name
Write-host "Processing Department: $NAME" 
$ParName =  $dept.ParentName
#Write-host "Parent Name1: $ParName"
$ID = $Dept.OID
$ParID = $dept.parentID
$ParOU = ""

if ($Name -eq "ROOT DEPARTEMT" -or $name -eq "OTHER EXCLUSION" -or $name -like "--*" -or $name -like "*rows*") ### Ignore non useful data
{ 
Write-host "Ignoring: $Name" -Fore Magenta 
Write-host "END processing for: $name" -for Cyan
Write-host ""
}

Else 
{
If ($ParName -ne "ROOT DEPARTEMT" ) 
{
### While Loop to build the parent OU path from the heierarchy ###
###------------------------------------------------
while ($ParName -ne "ROOT DEPARTEMT"){
#Write-host " Building OU name" -for Green
if ($ParName -ne "ROOT DEPARTEMT") {
$ParOU1 =  $ParOU1 + "OU=" + $ParName + ","
$Dept = $DEPTS |where {$_.name -eq $ParName}
$ParName = $Dept.ParentName

}
}
}


$ParOU =  $ParOU1 + $rootOU ### Parent OU
$ParOU = $ParOU -replace "&" , "and"
$Name = $Name -replace "&" , "and"
#Write-host "Final Parent OU: $ParOU"
$FinOU = "OU=" + $Name + "," + $ParOU
$FinOU = $FinOU -replace "&", "and"
#Write-host "Final OU: $FinOU" -for Green
#Write-host "Processing record: $Count"

$count = $count + 1

### Check and Create OU if it does not exist ###
###------------------------------------------------
if(![adsi]::Exists("LDAP://$FinOU"))
{ 
Write-host "OU does not exist." -fore Yellow
Write-host "Creating OU: $FinOU" -fore Yellow
new-adorganizationalUnit -name $Name -path $ParOU #-ProtectedFromAccidentalDeletion $False #-whatif
}
else {Write-host "OU is present" -Fore Green


#############################################################################
#For MIM Config file updates to OU structure#
#############################################################################

### Check miiserver.exe.config for OU configuration
###------------------------------------------------
$Filepath = "C:\Program Files\Microsoft Forefront Identity Manager\2010\Synchronization Service\Bin\miiserver.exe.config" ## Production file
$fileContent = Get-Content $filePath

### Check if config for the department exists
###------------------------------------------------
$DeptOU = "OU=" + $Name + "," + $ParOU1
$DeptOU = $DeptOU -replace "&" , "and"
$textToAdd = '    <add key="' + $name + '" value="' + $DeptOU + '"/>'
$Newline = "`r`n"
$KeyCheck = Select-String -Path $filePath -pattern $textToAdd
$DeptKey = '<add key="' + $name + '"'
#Write-host "Department key is $deptkey"
$KeyCheck1 = Select-String -Path $filePath -pattern $DeptKey

if (!$KeyCheck) {
if ($KeyCheck1) {
### If the department had a previous heirarchy, this will be replaced in the config file.
Write-host "Prevoius Config key exists" -fore yellow
Write-host "Replacing Config key " -fore yellow
$Line = $KeyCheck1.line
$fileContent = $fileContent -replace $line , $textToAdd
$fileContent | Set-Content $filePath
$restartCheck  = 1
}
Else {
### If the department is new in the  heirarchy, this will be added to the config file.
Write-host "Config key does not exist" -fore yellow
Write-host "Writing Config key " -fore yellow
$fileContent[193] += $Newline
$fileContent[193] += $textToAdd
$fileContent | Set-Content $filePath
$restartCheck  = 1}
}
else {
Write-host "Config key is present" -Fore Green
}
### Reset variables  ###
###------------------------------------------------
$ParOU1 = ""
$DeptOU = ""

} 
Write-host "END processing for $name" -for Cyan
Write-host ""
}
}
### Check if the config file has changed and the service must be restarted.
###------------------------------------------------
If ($restartCheck -eq 1 ) {
Write-host ""
Write-host "Config changes made. Restarting FIM Sync service." -Fore Green
stop-Service "Forefront Identity Manager Synchronization Service"
Start-Service "Forefront Identity Manager Synchronization Service"
Write-host "Proccess complete" -fore green
}
Else {
Write-host "No change to config. FIM Sync service will not be restarted." -fore Green
Write-host "Proccess complete." -fore green}
### End of script.