echo off
CLS
ver| find /i "6.1"
IF NOT errorlevel 1 goto Start
Cls
ver| find /i "6.2"
IF NOT errorlevel 1 goto Start
Cls
ver| find /i "6.3"
IF NOT errorlevel 1 goto Start
Exit
:Start
reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\AppV\ | find "Client"
IF NOT errorlevel 1 Goto End
CLS

COLOR 0C
Echo .                    Bidvest Automotive Software Update
Echo .                        Please wait a few seconds
Echo(
Echo(
Echo(
Echo(
PING 1.1.1.1 -n 1 -w 500 >NUL
Echo Preparing Installation...............
Echo(
Echo Please Do Not close this window.
Echo(
Echo(
Echo(
Echo(
PING 1.1.1.1 -n 1 -w 2000 >NUL
c:
dir c:\ | find /i "AppV"
IF NOT errorlevel 1 goto Invis
md c:\AppV

dir c:\ | find /i "AppV"
IF NOT errorlevel 1 goto Invis
Exit

:Invis


dir c:\AppV | find /i "Invis"
IF NOT errorlevel 1 goto Wait
Start /min Xcopy \\mccarthyltd.local\NETLOGON\AppV\Invisible.vbs c:\AppV /Y

:Wait
dir c:\AppV | find /i "Wait"
IF NOT errorlevel 1 goto Prompt

Start /min Xcopy \\mccarthyltd.local\NETLOGON\AppV\wait10.bat c:\AppV /Y
Start /min Xcopy \\mccarthyltd.local\NETLOGON\AppV\elevate.cmd c:\AppV /Y
Start /min Xcopy \\mccarthyltd.local\NETLOGON\AppV\elevate.vbs c:\AppV /Y
Start /min Xcopy \\mccarthyltd.local\NETLOGON\AppV\AppVStart.reg c:\AppV /Y
Start /min Xcopy \\mccarthyltd.local\NETLOGON\AppV\AppVend.reg c:\AppV /Y

:Prompt
Start /min Xcopy \\mccarthyltd.local\NETLOGON\AppV\BidvestAutoPrompt.bat c:\AppV /Y

PING 1.1.1.1 -n 1 -w 2000 >NUL
c:
cd c:\AppV\

c:\AppV\BidvestAutoPrompt.bat

:End
Exit

