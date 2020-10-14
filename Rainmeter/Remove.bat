Echo off
Dir C:\rainmeter\rainmeter\ | find "Rainmeter.exe"
IF NOT errorlevel 1 GOTO Remove
echo Missing %ComputerName% %date% %time% raindist>>\\196.14.34.107\distribution\remove\Missing-%computername%.txt

Exit

:Remove
Echo off


Taskkill /f /im rainmeter.exe 

RD c:\rainmeter /s /q


Dir C:\rainmeter\rainmeter\ | find "Rainmeter.exe"
IF NOT errorlevel 1 GOTO :Failed

echo Success %ComputerName% %date% %time% raindist>>\\196.14.34.107\distribution\remove\Success-%computername%.txt
Exit

:Failed

echo Failed %ComputerName% %date% %time% raindist>>\\196.14.34.107\distribution\remove\Failed-%computername%.txt

Exit

