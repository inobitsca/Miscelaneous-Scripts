$users= Import-csv c:\temp\newusers.txt
New-ADOrganizationalUnit -Name PaySpace -Path 'DC=Payspace,DC=com'
$pw = Read-Host "password?" -AsSecureString 
Foreach ($user in $users) {

New-ADUser $User.SAM  -DisplayName $user.displayname -Surname $user.LastName -GivenName $User.Firstname -OtherAttributes @{mail=$User.UPN} -AccountPassword $pw -Enabled $true -Path 'OU=PaySpace,DC=Payspace,DC=com'}