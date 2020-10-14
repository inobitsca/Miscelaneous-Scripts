clear-host

# Install Windows Roles and Features
Import-Module ServerManager
Add-WindowsFeature DNS

# Configure DNS
dnscmd /zoneadd fabrikam.com /primary
dnscmd /config fabrikam.com /AllowUpdate 1
dnscmd /zoneadd 0.168.192.in-addr.arpa /primary
dnscmd /config 0.168.192.in-addr.arpa /AllowUpdate 1
dnscmd /recordadd fabrikam.com fiabdc01 A 192.168.0.60 
dnscmd /recordadd fabrikam.com fiabfim01 A 192.168.0.61
dnscmd /recordadd fabrikam.com fiabpc01 A 192.168.0.62
dnscmd /recordadd 0.168.192.in-addr.arpa 60 PTR fiabdc01.fabrikam.com
dnscmd /recordadd 0.168.192.in-addr.arpa 61 PTR fiabfim01.fabrikam.com
dnscmd /recordadd 0.168.192.in-addr.arpa 62 PTR fiabpc01.fabrikam.com
dnscmd /recordadd fabrikam.com "@" NS fiabdc01.fabrikam.com
dnscmd /recordadd 0.168.192.in-addr.arpa "@" NS fiabdc01.fabrikam.com
dnscmd /recorddelete fabrikam.com "@" NS fiabdc01 /f
dnscmd /recorddelete 0.168.192.in-addr.arpa "@" NS fiabdc01 /f

# Run DCPromo
dcpromo /answer:d:\Demo_Setup\dc_setup\fabrikam.txt
