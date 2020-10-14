Echo Off
Color 0c
Echo ------------------------ Installing App-V Client -------------------- 
Echo ------------------ Please DO NOT close this window.------------------ 

dir c:\ | find /i "AppV"
IF NOT errorlevel 1 goto Start
md c:\AppV

dir c:\ | find /i "AppV"
IF NOT errorlevel 1 goto Start
Exit

:Start
CLS
Color 0a
Echo ------------------------ Installing App-V Client --------------------
Echo ------------------ Please DO NOT close this window.------------------ 

reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\AppV\ | find "Client"
IF NOT errorlevel 1 Goto Client
CLS
Echo ------------------------ Installing App-V Client --------------------
Echo ------------------ Please DO NOT close this window.------------------ 
Reg Query HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\ | find "10.0"
IF NOT errorlevel 1 goto DotNet
CLS
Echo ------------------------ Installing App-V Client --------------------
Echo ------------------ Please DO NOT close this window.------------------ 
Reg Query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\VisualStudio\ | find "10.0"
IF NOT errorlevel 1 goto DotNet
CLS
Color 0c
Echo ------------------------ Installing App-V Client --------------------
Echo ------------------ Please DO NOT close this window.------------------ 

start /min \\mccarthyltd.local\NETLOGON\AppV\AppVCP2010.bat

Exit

REM Check for DotNet 4.0
:DotNet
Reg Query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4" | find "Full"
IF NOT errorlevel 1 Goto CheckPS3
goto InstDN4
Exit

REM Check for PowerShell 3.0
:CheckPS3
CLS
Color 0a
Echo ------------------------ Installing App-V Client --------------------
Echo ------------------ Please DO NOT close this window.------------------ 

reg Query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell | find "3"
IF NOT errorlevel 1 goto STARTClient
goto PowerShell

REM Install App-V Client
:STARTClient

Echo off
ipconfig | find /i "10.128.226."
IF NOT errorlevel 1 xcopy \\10.128.226.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.46.188."
IF NOT errorlevel 1 xcopy \\10.46.188.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.64.226."
IF NOT errorlevel 1 xcopy \\10.64.226.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.64.248."
IF NOT errorlevel 1 xcopy \\10.64.248.231\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.64.248."
IF NOT errorlevel 1 xcopy \\10.64.248.229\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.96.195."
IF NOT errorlevel 1 xcopy \\10.96.195.242\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.96.222."
IF NOT errorlevel 1 xcopy \\10.96.222.242\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.96.142."
IF NOT errorlevel 1 xcopy \\10.96.142.242\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.96.1."
IF NOT errorlevel 1 xcopy \\10.96.1.242\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.96.192."
IF NOT errorlevel 1 xcopy \\10.96.192.242\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.96.243."
IF NOT errorlevel 1 xcopy \\10.96.243.243\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.96.193."
IF NOT errorlevel 1 xcopy \\10.96.193.242\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.96.215."
IF NOT errorlevel 1 xcopy \\10.96.215.242\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.64.175."
IF NOT errorlevel 1 xcopy \\10.64.175.243\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.96.253."
IF NOT errorlevel 1 xcopy \\10.96.253.243\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.96.231."
IF NOT errorlevel 1 xcopy \\10.96.231.242\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.64.235."
IF NOT errorlevel 1 xcopy \\10.64.235.243\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.96.254."
IF NOT errorlevel 1 xcopy \\10.96.254.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.96.196."
IF NOT errorlevel 1 xcopy \\10.96.196.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.41.247."
IF NOT errorlevel 1 xcopy \\10.41.247.242\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.41.246."
IF NOT errorlevel 1 xcopy \\10.41.246.242\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.64.167."
IF NOT errorlevel 1 xcopy \\10.64.167.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.64.239."
IF NOT errorlevel 1 xcopy \\10.64.239.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.64.249."
IF NOT errorlevel 1 xcopy \\10.64.249.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.128.240."
IF NOT errorlevel 1 xcopy \\10.128.240.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.128.212."
IF NOT errorlevel 1 xcopy \\10.128.212.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.128.244."
IF NOT errorlevel 1 xcopy \\10.128.244.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.128.244."
IF NOT errorlevel 1 xcopy \\10.128.244.219\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.128.144."
IF NOT errorlevel 1 xcopy \\10.128.144.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.46.180."
IF NOT errorlevel 1 xcopy \\10.46.180.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.46.232."
IF NOT errorlevel 1 xcopy \\10.46.232.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.46.232."
IF NOT errorlevel 1 xcopy \\10.46.232.219\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.46.236."
IF NOT errorlevel 1 xcopy \\10.46.236.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.41.247."
IF NOT errorlevel 1 xcopy \\10.41.247.245\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.41.247."
IF NOT errorlevel 1 xcopy \\10.41.247.244\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.64.176."
IF NOT errorlevel 1 xcopy \\10.64.176.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.64.227."
IF NOT errorlevel 1 xcopy \\10.64.227.210\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.64.227."
IF NOT errorlevel 1 xcopy \\10.64.227.209\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.64.218."
IF NOT errorlevel 1 xcopy \\10.64.218.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.64.252."
IF NOT errorlevel 1 xcopy \\10.64.252.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.64.132."
IF NOT errorlevel 1 xcopy \\10.64.132.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.64.132."
IF NOT errorlevel 1 xcopy \\10.64.132.219\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.46.239."
IF NOT errorlevel 1 xcopy \\10.46.239.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.131.51."
IF NOT errorlevel 1 xcopy \\10.131.51.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.43.250."
IF NOT errorlevel 1 xcopy \\10.43.250.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.43.250."
IF NOT errorlevel 1 xcopy \\10.43.250.219\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.96.194."
IF NOT errorlevel 1 xcopy \\10.96.194.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.42.253."
IF NOT errorlevel 1 xcopy \\10.42.253.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.42.239."
IF NOT errorlevel 1 xcopy \\10.42.239.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.42.239."
IF NOT errorlevel 1 xcopy \\10.42.239.219\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.96.225."
IF NOT errorlevel 1 xcopy \\10.96.225.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.96.235."
IF NOT errorlevel 1 xcopy \\10.96.235.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.96.235."
IF NOT errorlevel 1 xcopy \\10.96.235.219\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.96.153."
IF NOT errorlevel 1 xcopy \\10.96.153.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.96.206."
IF NOT errorlevel 1 xcopy \\10.96.206.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.96.206."
IF NOT errorlevel 1 xcopy \\10.96.206.219\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.96.152."
IF NOT errorlevel 1 xcopy \\10.96.152.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.96.152."
IF NOT errorlevel 1 xcopy \\10.96.152.219\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.96.227."
IF NOT errorlevel 1 xcopy \\10.96.227.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.96.236."
IF NOT errorlevel 1 xcopy \\10.96.236.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.41.246."
IF NOT errorlevel 1 xcopy \\10.41.246.245\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.41.246."
IF NOT errorlevel 1 xcopy \\10.41.246.244\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.46.233."
IF NOT errorlevel 1 xcopy \\10.46.233.107\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.64.220."
IF NOT errorlevel 1 xcopy \\10.64.220.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.96.202."
IF NOT errorlevel 1 xcopy \\10.96.202.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.64.146."
IF NOT errorlevel 1 xcopy \\10.64.146.210\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.64.146."
IF NOT errorlevel 1 xcopy \\10.64.146.209\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.96.149."
IF NOT errorlevel 1 xcopy \\10.96.149.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.96.231."
IF NOT errorlevel 1 xcopy \\10.96.231.245\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.96.231."
IF NOT errorlevel 1 xcopy \\10.96.231.244\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.96.231."
IF NOT errorlevel 1 xcopy \\10.96.231.243\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.64.216."
IF NOT errorlevel 1 xcopy \\10.64.216.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.69.43."
IF NOT errorlevel 1 xcopy \\10.69.43.150\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.64.236."
IF NOT errorlevel 1 xcopy \\10.64.236.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.64.205."
IF NOT errorlevel 1 xcopy \\10.64.205.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.69.43."
IF NOT errorlevel 1 xcopy \\10.69.43.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.46.241."
IF NOT errorlevel 1 xcopy \\10.46.241.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.64.251."
IF NOT errorlevel 1 xcopy \\10.64.251.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.96.251."
IF NOT errorlevel 1 xcopy \\10.96.251.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.64.238."
IF NOT errorlevel 1 xcopy \\10.64.238.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.41.1."
IF NOT errorlevel 1 xcopy \\10.41.1.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.96.237."
IF NOT errorlevel 1 xcopy \\10.96.237.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.97.4."
IF NOT errorlevel 1 xcopy \\10.97.4.250\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.131.131."
IF NOT errorlevel 1 xcopy \\10.131.131.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.96.150."
IF NOT errorlevel 1 xcopy \\10.96.150.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.128.245."
IF NOT errorlevel 1 xcopy \\10.128.245.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.128.250."
IF NOT errorlevel 1 xcopy \\10.128.250.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.128.248."
IF NOT errorlevel 1 xcopy \\10.128.248.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.46.230."
IF NOT errorlevel 1 xcopy \\10.46.230.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.96.238."
IF NOT errorlevel 1 xcopy \\10.96.238.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.128.211."
IF NOT errorlevel 1 xcopy \\10.128.211.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.46.238."
IF NOT errorlevel 1 xcopy \\10.46.238.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.96.234."
IF NOT errorlevel 1 xcopy \\10.96.234.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.64.234."
IF NOT errorlevel 1 xcopy \\10.64.234.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.96.223."
IF NOT errorlevel 1 xcopy \\10.96.223.220\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "10.96.232."
IF NOT errorlevel 1 xcopy \\10.96.232.50\software\appv_client_setup.exe c:\AppV /Y
ipconfig | find /i "196.14.34."
IF NOT errorlevel 1 xcopy \\196.14.34.107\software\appv_client_setup.exe c:\AppV /Y


Start /min  c:\AppV\appv_client_setup.exe /q /ACCEPTEULA
CLS
echo off
SET /A XCOUNT=610
:loop
CLS
SET /A XCOUNT-=10
color 0c
Echo ------------------------ Installing App-V Client --------------------
Echo ------------------ Please DO NOT close this window.------------------
Echo(
Echo ------------------ This may take up to %XCOUNT% seconds.------------------  

PING 1.1.1.1 -n 1 -w 10000 >NUL
SET /A XCOUNT-=10
cls
color 0a
Echo ------------------------ Installing App-V Client --------------------
Echo ------------------ Please DO NOT close this window.------------------
Echo(
Echo ------------------ This may take up to %XCOUNT% seconds.------------------  

PING 1.1.1.1 -n 1 -w 10000 >NUL

reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\AppV\ | find "Client"
IF NOT errorlevel 1 Goto Client

IF "%XCOUNT%" == "0" GOTO Failed
GOTO loop

:Failed
Echo %computername% %date% App-V client Failed >>\\196.14.34.107\Stuff$\AppVCheck\AppVClient\FAILED%computername%.txt
Color 0c
Echo ------------------------ Installation failed----------------------  
PING 1.1.1.1 -n 1 -w 10000 >NUL
Exit

:Client
c:
cd c:\AppV\
reg import AppVEnd.reg
Echo %computername% %date% App-V client installed >>\\196.14.34.107\Stuff$\AppVCheck\AppVClient\%computername%.txt
Color 0a
Echo ------------------------ Installation Succeeded!----------------------  
PING 1.1.1.1 -n 1 -w 10000 >NUL
Exit

:PowerShell
c:
cd c:\AppV\
elevate \\mccarthyltd.local\NETLOGON\AppV\AppVPS3.bat

Exit

:InstDN4
c:
cd c:\AppV\
elevate \\mccarthyltd.local\NETLOGON\AppV\AppVDotNet.bat

Exit