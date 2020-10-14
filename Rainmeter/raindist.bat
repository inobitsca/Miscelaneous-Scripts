Echo off
REM Exclude BRAC Polokwane
ipconfig | find "10.96.210"
IF NOT errorlevel 1 Exit


SET /A XCOUNT=0
Dir C:\rainmeter\rainmeter\ | find "meter.exe"
IF NOT errorlevel 1 GOTO UPDATE

Start \\mccarthyltd.local\netlogon\raindist1.bat
REM Goto APP-V
Exit

:Update
Echo off
echo %ComputerName% %date% %time% raindist>>\\196.14.34.107\distribution\checkin\%computername%.txt

Taskkill /f /im rainmeter.exe 


start /min xcopy \\196.14.34.107\distribution\Rainmeter\Skins\illustro\BidvestAuto\bidvestauto.ini c:\rainmeter\Rainmeter\Skins\illustro\BidvestAuto\ /Y /Q

start /min xcopy \\196.14.34.107\distribution\Rainmeter\Skins\illustro\BidvestAuto\Background.png c:\rainmeter\Rainmeter\Skins\illustro\BidvestAuto\ /Y /Q

start /min xcopy \\196.14.34.107\distribution\Rainmeter.ini c:\rainmeter\rainmeter\illustro\BidvestAuto\ /Y /Q


start c:\rainmeter\rainmeter\rainmeter.exe

Exit

# Check APP-V
:app-v

Echo off
reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\AppV\ | find "Client"
IF NOT errorlevel 1 Exit

reg Query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell | find "3"
IF NOT errorlevel 1 goto Start /min \\mccarthyltd.local\netlogon\AppVInst.bat

Exit

:End