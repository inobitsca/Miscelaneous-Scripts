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

Write-host "Creating SPNs for MIM" -fore Cyan


$set1 = "Setspn -S http/" + $mimportfqdn  + " " +  $domNB + "\MIMSharePoint"
$set2 = "Setspn -S http/" + $MIMPort + " " + $domNB + "\MIMSharePoint"
$set3 = "Setspn -S MIMService/" + $mimportfqdn + " " + $domNB + "\MIMService"
$set4 = "Setspn -S MIMSync/" + $mimSyncfqdn + " " +  $domNB + "\MIMSync"

iex $set1 
iex $set2 
iex $set3 
iex $set4

Write-host "Creating MIM service accounts" -fore cyan

$sp = ConvertTo-SecureString $pass –asplaintext –force

New-ADUser –SamAccountName MIMAdmin –name MIMAdmin -Description "MIM Administration account" -DisplayName "MIM Admin"
Set-ADAccountPassword –identity MIMAdmin –NewPassword $sp
Set-ADUser –identity MIMAdmin –Enabled 1 –PasswordNeverExpires 1

New-ADUser –SamAccountName MIMMA –name MIMMA -Description "MIM Management Agent service account" -DisplayName "MIM Management Agent"
Set-ADAccountPassword –identity MIMMA –NewPassword $sp
Set-ADUser –identity MIMMA –Enabled 1 –PasswordNeverExpires 1

New-ADUser –SamAccountName MIMSync –name MIMSync -Description "MIM Sync service account" -DisplayName "MIM Sync"
Set-ADAccountPassword –identity MIMSync –NewPassword $sp
Set-ADUser –identity MIMSync –Enabled 1 –PasswordNeverExpires 1

New-ADUser –SamAccountName MIMService –name MIMService -Description "MIM Portal service account" -DisplayName "MIM Portal"
Set-ADAccountPassword –identity MIMService –NewPassword $sp
Set-ADUser –identity MIMService –Enabled 1 –PasswordNeverExpires 1

New-ADUser –SamAccountName MIMSSPR –name MIMSSPR  -Description "MIM Single Signon and Password Reset service account" -DisplayName "MIM Single Signon"
Set-ADAccountPassword –identity MIMSSPR –NewPassword $sp
Set-ADUser –identity MIMSSPR –Enabled 1 –PasswordNeverExpires 1

New-ADUser –SamAccountName MIMSharePoint –name MIMSharePoint  -Description "MIM SharePoint service account" -DisplayName "MIM SharePoint"
Set-ADAccountPassword –identity MIMSharePoint –NewPassword $sp
Set-ADUser –identity MIMSharePoint –Enabled 1 –PasswordNeverExpires 1

New-ADUser –SamAccountName MIMSqlServer –name MIMSqlServer -Description "MIM SQL service account" -DisplayName "MIM SQL"
Set-ADAccountPassword –identity MIMSqlServer –NewPassword $sp
Set-ADUser –identity MIMSqlServer –Enabled 1 –PasswordNeverExpires 1

New-ADUser –SamAccountName MIMBackupAdmin –name MIMBackupAdmin -Description "MIM Backup service account" -DisplayName "MIM Backup"
Set-ADAccountPassword –identity MIMBackupAdmin –NewPassword $sp
Set-ADUser –identity MIMBackupAdmin –Enabled 1 -PasswordNeverExpires 1

Write-host = "Creating MIM Groups" -fore cyan

New-ADGroup –name GRP_MIMSyncAdmins –GroupCategory Security –GroupScope Global         –SamAccountName MIMSyncAdmins
New-ADGroup –name GRP_MIMSyncOperators –GroupCategory Security –GroupScope Global         –SamAccountName MIMSyncOperators
New-ADGroup –name GRP_MIMSyncJoiners –GroupCategory Security –GroupScope Global         –SamAccountName MIMSyncJoiners
New-ADGroup –name GRP_MIMSyncBrowse –GroupCategory Security –GroupScope Global         –SamAccountName MIMSyncBrowse
New-ADGroup –name GRP_MIMSyncPasswordReset –GroupCategory Security –GroupScope Global          –SamAccountName MIMSyncPasswordReset
Add-ADGroupMember -identity GRP_MIMSyncAdmins -Members $Env:username,MIMService,MIMAdmin,MIMSync




#Install Required roles and Features on MIM Service Server (Portal)

# Import-module ServerManager
# Install-WindowsFeature Web-WebServer, Net-Framework-Features,rsat-ad-powershell,Web-Mgmt-Tools,Application-Server,Windows-Identity-Foundation,Server-Media-Foundation,Xps-Viewer –includeallsubfeature -restart -source $source -ComputerName $MIMPort+"."+$fullDom
