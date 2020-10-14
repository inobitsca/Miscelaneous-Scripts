clear-host

# Set TCP/IP
netsh interface ip set address "Local Area Connection" static 192.168.0.62 255.255.255.0 192.168.0.1
netsh interface ip set dns "Local Area Connection" static 192.168.0.60

# Rename Server to FIABPC01
$ComputerName = Get-WmiObject -Class Win32_ComputerSystem
$ComputerName.Rename("FIABPC01")
#$ComputerName.Rename("FIABPC01","Passw0rd","administrator")

# Set X: as Letter for DVD Drive
$drive = Get-WmiObject -Class win32_volume -Filter "DriveLetter = 'd:'"
Set-WmiInstance -input $drive -Arguments @{DriveLetter="x:"; Label=""}

# Set D: as Letter for FIAB_Install.vhd
$drive = Get-WmiObject -Class win32_volume -Filter "DriveLetter = 'e:'"
Set-WmiInstance -input $drive -Arguments @{DriveLetter="D:"; Label="Setup Files"}

# Restart Server
Restart-Computer