$users= Import-csv c:\temp\newusers.txt
$pw = Read-Host "password?" -AsSecureString 
Foreach ($user in $users) {

Get-ADUser $User.SAM  | Set-ADAccountPassword  -Reset -NewPassword $pw}