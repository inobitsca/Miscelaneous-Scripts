CLS
import-module activedirectory 

Write-host "MIM Server Variables"  -fore Cyan

Write-host "You will now be asked to enter the variables needed for MIM deployment" -fore Green
Write-host "The account you are now using will be added to the MIMAdmins Group" -fore Green

$MIMPort = read-host "Enter the MIM Portal server NETBIOS name"
$MIMSync = read-host "Enter the MIM Sync server NETBIOS name"
$DomNB = read-host "Enter the domain NETBIOS name"
$FullDom = read-host "Enter the full domain name e.g. domain.co.za"
$pass =  read-host "Enter the password for the service account"
#$s = read-host "Enter the full UPN path to a share containing Windows Source files e.g. \\server\share\WindowsFiles\"
#$source = $s + "sources\sxs\"
$mimportfqdn = $MIMPort+"."+$fullDom
$mimSyncfqdn = $MIMSync+"."+$fullDom




$set1 = "Setspn -S http/" + $mimportfqdn  + " " +  $domNB + "\SVCMIMSharePoint"
$set2 = "Setspn -S http/" + $MIMPort + " " + $domNB + "\SVCMIMSharePoint"
$set3 = "Setspn -S MIMService/" + $mimportfqdn + " " + $domNB + "\SVCMIMService"
$set4 = "Setspn -S MIMSync/" + $mimSyncfqdn + " " +  $domNB + "\SVCMIMSync"



Write-host "Creating MIM service accounts" -fore cyan

$sp = ConvertTo-SecureString $pass –asplaintext –force

New-ADUser –SamAccountName SVCMIMAdmin –Name SVCMIMAdmin -Description "MIM Administration account" -DisplayName "MIM Admin Account" -AccountPassword $SP
Set-ADAccountPassword –identity SVCMIMAdmin –NewPassword $sp
Set-ADUser –identity SVCMIMAdmin –Enabled 1 –PasswordNeverExpires 1

New-ADUser –SamAccountName SVCMIMADMA –Name SVCMIMADMA -Description "MIM AD Management Agent service account" -DisplayName "MIM AD Management Agent" -AccountPassword $SP
Set-ADAccountPassword –identity SVCMIMMA –NewPassword $sp
Set-ADUser –identity SVCMIMADMA –Enabled 1 –PasswordNeverExpires 1

New-ADUser –SamAccountName SVCMIMSync –Name SVCMIMSync -Description "MIM Sync service account" -DisplayName "MIM Sync Service" -AccountPassword $SP
Set-ADAccountPassword –identity SVCMIMSync –NewPassword $sp
Set-ADUser –identity SVCMIMSync –Enabled 1 –PasswordNeverExpires 1

New-ADUser –SamAccountName SVCMIMService –Name SVCMIMService -Description "MIM Portal service account" -DisplayName "MIM Portal Service" -AccountPassword $SP
Set-ADAccountPassword –identity SVCMIMService –NewPassword $sp
Set-ADUser –identity SVCMIMService –Enabled 1 –PasswordNeverExpires 1

New-ADUser –SamAccountName SVCMIMSSPR –Name SVCMIMSSPR  -Description "MIM Single Signon and Password Reset service account" -DisplayName "MIM SSPR Service" -AccountPassword $SP
Set-ADAccountPassword –identity SVCMIMSSPR –NewPassword $sp
Set-ADUser –identity SVCMIMSSPR –Enabled 1 –PasswordNeverExpires 1

New-ADUser –SamAccountName SVCMIMSharePoint –Name SVCMIMSharePoint  -Description "MIM SharePoint service account" -DisplayName "MIM SharePoint Service" -AccountPassword $SP
#Set-ADAccountPassword –identity SVCMIMSharePoint –NewPassword $sp
Set-ADUser –identity SVCMIMSharePoint –Enabled 1 –PasswordNeverExpires 1

New-ADUser –SamAccountName SVCMIMSqlServer –Name SVCMIMSqlServer -Description "MIM SQL service account" -DisplayName "MIM SQL Service" -AccountPassword $SP
Set-ADAccountPassword –identity SVCMIMSqlServer –NewPassword $sp
Set-ADUser –identity SVCMIMSqlServer –Enabled 1 –PasswordNeverExpires 1

New-ADUser –SamAccountName SVCMIMBackupAdmin –Name SVCMIMBackupAdmin -Description "MIM Backup service account" -DisplayName "MIM Backup Service" -AccountPassword $SP
Set-ADAccountPassword –identity SVCMIMBackupAdmin –NewPassword $sp
Set-ADUser –identity SVCMIMBackupAdmin –Enabled 1 -PasswordNeverExpires 1

Write-host = "Creating MIM Groups" -fore cyan

New-ADGroup –name GRP_MIMSyncAdmins –GroupCategory Security –GroupScope Global         –SamAccountName SVCMIMSyncAdmins
New-ADGroup –name GRP_MIMSyncOperators –GroupCategory Security –GroupScope Global         –SamAccountName SVCMIMSyncOperators
New-ADGroup –name GRP_MIMSyncJoiners –GroupCategory Security –GroupScope Global         –SamAccountName SVCMIMSyncJoiners
New-ADGroup –name GRP_MIMSyncBrowse –GroupCategory Security –GroupScope Global         –SamAccountName SVCMIMSyncBrowse
New-ADGroup –name GRP_MIMSyncPasswordReset –GroupCategory Security –GroupScope Global          –SamAccountName SVCMIMSyncPasswordReset
Add-ADGroupMember -identity GRP_MIMSyncAdmins -Members $Env:username,SVCMIMService,SVCMIMAdmin,SVCMIMSync

Write-host "Creating SPNs for MIM" -fore Cyan
iex $set1 
iex $set2 
iex $set3 
iex $set4


#Install Required roles and Features on MIM Service Server (Portal)

# Import-module ServerManager
# Install-WindowsFeature Web-WebServer, Net-Framework-Features,rsat-ad-powershell,Web-Mgmt-Tools,Application-Server,Windows-Identity-Foundation,Server-Media-Foundation,Xps-Viewer –includeallsubfeature -restart -source $source -ComputerName $MIMPort+"."+$fullDom
