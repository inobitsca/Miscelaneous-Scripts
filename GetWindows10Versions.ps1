import-module ActiveDirectory
 
$WIN1803 = Get-ADComputer -Properties OperatingSystem,OperatingSystemVersion  -Filter  'operatingsystem -like "*10*" -and OperatingSystemVersion -like "*17134*"' |Measure
$WIN1709 = Get-ADComputer -Properties OperatingSystem,OperatingSystemVersion  -Filter  'operatingsystem -like "*10*" -and OperatingSystemVersion -like "*16299*"' |Measure
$WIN1703 = Get-ADComputer -Properties OperatingSystem,OperatingSystemVersion  -Filter  'operatingsystem -like "*10*" -and OperatingSystemVersion -like "*15063*"' |Measure
$WIN1607 = Get-ADComputer -Properties OperatingSystem,OperatingSystemVersion  -Filter  'operatingsystem -like "*10*" -and OperatingSystemVersion -like "*14393*"' |Measure
$Win1511  = Get-ADComputer -Properties OperatingSystem,OperatingSystemVersion  -Filter  'operatingsystem -like "*10*" -and OperatingSystemVersion -like "*10586*"' |Measure
$WIN1507 = Get-ADComputer -Properties OperatingSystem,OperatingSystemVersion  -Filter  'operatingsystem -like "*10*" -and OperatingSystemVersion -like "*10240*"' |Measure
write-host "Windows 10 1803:" $WIN1803.count
write-host "Windows 10 1709:" $WIN1709.count
write-host "Windows 10 1703:" $WIN1703.count
write-host "Windows 10 1607:" $WIN1607.count
write-host "Windows 10 1511:" $WIN1507.count
write-host "Windows 10 1507:" $WIN1507.count  

