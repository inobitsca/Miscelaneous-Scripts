$cred=Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://hoex01.numsa.org.za/PowerShell/ -Authentication Kerberos -Credential $cred
Import-PSSession $session
(Get-Host).UI.RawUI.BackgroundColor= "blue"
cls
