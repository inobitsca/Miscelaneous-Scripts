Clear-host

# DNS Active Directory Integrated
dnscmd /zoneresettype fabrikam.com /dsprimary
dnscmd /zoneresettype 0.168.192.in-addr.arpa /dsprimary

# Create SQL Service Account
Import-Module ActiveDirectory
New-ADUser SQLService -AccountPassword (ConvertTo-SecureString -AsPlainText "Passw0rd" -Force) -Enabled $true -Path "CN=Users,DC=FABRIKAM,DC=COM" -PasswordNeverExpires $true


# Exchange Server 2007 Prereq
Import-Module ServerManager
Add-WindowsFeature RSAT-ADDS,Web-Server,Web-Metabase,Web-Lgcy-Mgmt-Console,Web-Dyn-Compression,Web-Windows-Auth,Web-Basic-Auth,Web-Digest-Auth,RPC-Over-HTTP-Proxy

# Restart Server
Restart-Computer