clear-host

# Prepare AD for Exchange
D:\Software\Exchange_2007_SP3\setup.com /PrepareAD /OrganizationName:Fabrikam
D:\Software\Exchange_2007_SP3\setup.com /PrepareAllDomains

# Install Exchange Roles
D:\Software\Exchange_2007_SP3\setup.com /mode:install /Roles:"ClientAccess,HubTransport,Mailbox"

# Restart Server
Restart-Computer