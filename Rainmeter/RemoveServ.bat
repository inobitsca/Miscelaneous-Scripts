Echo off
Dir C:\rainmeter\rainmeter\ | find "Rainmeter.exe"
IF NOT errorlevel 1 GOTO Remove
echo Serv-Missing %ComputerName% %date% %time% raindist>>\\196.14.34.107\distribution\remove\Serv-Missing-%computername%.txt

Exit

:Remove
Echo off


Taskkill /f /im rainmeter.exe 

RD c:\rainmeter /s /q


Dir C:\rainmeter\rainmeter\ | find "Rainmeter.exe"
IF NOT errorlevel 1 GOTO :Failed

echo Serv-Success %ComputerName% %date% %time% raindist>>\\196.14.34.107\distribution\remove\Serv-Success-%computername%.txt
Exit

:Failed

echo Serv-Failed %ComputerName% %date% %time% raindist>>\\196.14.34.107\distribution\remove\Serv-Failed-%computername%.txt

Exit

