md c:\distribution\
net share distribution=c:\distribution /Grant:administrators,Full /Grant:users,read /users:1000

PowerShell
([wmiclass]’\\jnbex01\root\cimv2:Win32_Share’).Create(‘c:\temp\Office2010SP’, ‘Office2010SP’, 0, 12, ‘Office 2010 Service Packs’).ReturnValue 