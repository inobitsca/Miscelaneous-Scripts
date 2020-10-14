$users= Import-csv c:\temp\newusers.txt 
Foreach ($user in $users) {
# get-aduser -Identity $user.sam |  Move-ADObject -TargetPath "OU=payspace,DC=payspace,DC=com"
#get-aduser -Identity $user.sam | Set-ADUser  -UserPrincipalName $user.upn

get-aduser -Identity $user.sam | Rename-ADobject -newname $user.Displayname
}