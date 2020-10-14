Import-Module Activedirectory

$Encrypted
$user = ".\RouteAdmin" 
$password = ConvertTo-SecureString -string $encrypted 

#$cred=Get-Credential

$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://inazex01/PowerShell/ -Authentication Kerberos -Credential $cred
Import-PSSession $session
(Get-Host).UI.RawUI.BackgroundColor= "blue"
cls


$users= Get-ADUser -Properties mail -filter 'mail -NOTLIKE "*"'-SearchBase "OU=MIM,DC=inobitsza,DC=com"

Foreach ($user in $users) {
$Sam = $user.samaccountname
$UPN = $sam + "@inobitsza.com"
Set-aduser $SAM -UserPrincipalName $UPN

Enable-Mailbox -Identity $SAM -Alias $SAM

}
