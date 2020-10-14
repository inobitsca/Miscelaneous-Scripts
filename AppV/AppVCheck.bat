Echo Off
c:
cd c:\AppV\
reg import AppVStart.reg
REM  Check for App-V Client - Exit if found
reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\AppV\ | find "Client"
IF NOT errorlevel 1 Goto Client



REM  Check for C++ 2010 (64 bit)
Reg Query HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\ | find "10.0"
IF NOT errorlevel 1 goto DotNet

REM  Check for C++ 2010 (32 bit)
Reg Query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\VisualStudio\ | find "10.0"
IF NOT errorlevel 1 goto DotNet

start /min \\mccarthyltd.local\netlogon\AppV\AppVCP2010.bat
 Exit



:DotNet

Rem Check for .Net 4.0 Full

Reg Query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4" | find "Full"
IF NOT errorlevel 1 goto InstPS3
start /min \\mccarthyltd.local\netlogon\AppV\AppVDotNet.bat
Exit

:InstPS3

REM  Check for PowerShell 3.0
reg Query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell | find "3"
IF NOT errorlevel 1 goto InstClient
start /min \\mccarthyltd.local\netlogon\AppV\AppVPS3.bat
Exit

:InstClient
c:
cd c:\appv\

elevate \\mccarthyltd.local\netlogon\AppV\AppVClient.bat

Exit

:Client
reg import AppVEnd.reg
Echo %computername% %date% App-V client installed  >>\\196.14.34.107\Stuff$\AppVCheck\AppVClient\%computername%.txt

EXIT




Exit