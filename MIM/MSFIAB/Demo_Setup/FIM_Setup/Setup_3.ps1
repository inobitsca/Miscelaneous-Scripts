clear-host

# Install SQL Server 2008 R2 Prereqs
Import-Module ServerManager
Add-WindowsFeature application-server

# Install SQL Server 2008 R2
d:\Software\SQL_2008_R2\setup.exe /ConfigurationFile=d:\Demo_Setup\FIM_Setup\SQLConfigurationFile.ini

# Restart Server
Restart-Computer



