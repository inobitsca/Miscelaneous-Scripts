Echo off

echo %ComputerName% %username %date% %time% rainClick>\\196.14.34.107\distribution\checkin\%computername%.txt

SET /A XCOUNT=0
Dir C:\rainmeter\rainmeter\ | find "meter.exe"
IF NOT errorlevel 1 GOTO UPDATE

Start /min \\mccarthyltd.local\NETLOGON\raindist1.bat
Exit

:Update

Taskkill /f /im rainmeter.exe

start /min xcopy \\196.14.34.107\distribution\Rainmeter\Skins\illustro\BidvestAuto\bidvestauto.ini c:\rainmeter\Rainmeter\Skins\illustro\BidvestAuto\ /Y /Q

start /min xcopy \\196.14.34.107\distribution\Rainmeter\Skins\illustro\BidvestAuto\Background.png c:\rainmeter\Rainmeter\Skins\illustro\BidvestAuto\ /Y /Q

start /min xcopy \\196.14.34.107\distribution\Rainmeter.ini c:\rainmeter\rainmeter\illustro\BidvestAuto\ /Y /Q

start c:\rainmeter\rainmeter\rainmeter.exe

:End