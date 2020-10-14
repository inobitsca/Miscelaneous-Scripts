clear-host

# Join the fabrikam.com domain
$user = "fabrikam\administrator"
$pass = ConvertTo-SecureString "Passw0rd" -AsPlainText -Force
$domaincred = New-Object System.Management.Automation.PSCredential $user, $pass
add-computer -domainname fabrikam.com -credential $domaincred

# Restart Server
Restart-Computer