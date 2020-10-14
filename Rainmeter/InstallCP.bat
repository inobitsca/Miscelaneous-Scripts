Echo off
SET /A XCOUNT=0
echo %ComputerName% %date% %time% raindist1 >>\\196.14.34.107\distribution\Raindist1\%computername%.txt
Dir C:\rainmeter\rainmeter\ | find "meter.exe"
IF NOT errorlevel 1 GOTO CPLUS


CLS
ECHO  BBBBBBBB    IIIIIIIII  DDDDDDD   V           V   EEEEEEEEE  SSSSSSSSS  TTTTTTTTTT 
ECHO  B       B      II      D      D   V         V    E          S              TT
ECHO  B       B      II      D       D   V       V     E          S              TT
ECHO  B BBBBBB       II      D       D    V     V      EEEEE      SSSSSSSSS      TT
ECHO  B       B      II      D       D     V   V       E                  S      TT
ECHO  B       B      II      D      D       V V        E                  S      TT
ECHO  BBBBBBBB    IIIIIIIII  DDDDDDD         V         EEEEEEEEE  SSSSSSSSS      TT
ECHO 1
ECHO               AA        U       U    TTTTTTTTTTTTT     OOOOOOOO     
ECHO             A    A      U       U          TT         O        O    
ECHO            A      A     U       U          TT         O        o
ECHO            AAAAAAAA     U       U          TT         O        O   
ECHO           A        A    U       U          TT         O        O   
ECHO           A        A    U       U          TT         O        O
ECHO           A        A     UUUUUUU           TT          OOOOOOOO   
Echo .
Echo .
Echo .       Bidvest Automotive IT is now installing the new Desktop Communicator
Echo .                         ---------------------- 
Echo .                          Click YES if asked 
Echo .                         ----------------------
PING 1.1.1.1 -n 1 -w 2000 >NUL
Echo .                         ---------------------- 
Echo .                          Click YES if asked 
Echo .                         ----------------------
PING 1.1.1.1 -n 1 -w 2000 >NUL


:CheckDir

Echo off 
Dir C:\rainmeter\rainmeter\ | find "rainmeter.exe"
IF NOT errorlevel 1 GOTO CPLUS
Echo off 
Dir C: | find "rainmeter"
IF NOT errorlevel 1 GOTO COPY1
MD c:\rainmeter\

:COPY1

Echo off 
ipconfig | find /i "10.64.156."
IF NOT errorlevel 1 start /min xcopy \\10.64.156.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.128.226."
IF NOT errorlevel 1 start /min xcopy \\10.128.226.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.46.188."
IF NOT errorlevel 1 start /min xcopy \\10.46.188.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.64.226."
IF NOT errorlevel 1 start /min xcopy \\10.64.226.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.64.248."
IF NOT errorlevel 1 start /min xcopy \\10.64.248.231\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.64.248."
IF NOT errorlevel 1 start /min xcopy \\10.64.248.229\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.96.195."
IF NOT errorlevel 1 start /min xcopy \\10.96.195.242\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.96.222."
IF NOT errorlevel 1 start /min xcopy \\10.96.222.242\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.96.142."
IF NOT errorlevel 1 start /min xcopy \\10.96.142.242\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.96.1."
IF NOT errorlevel 1 start /min xcopy \\10.96.1.242\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.96.192."
IF NOT errorlevel 1 start /min xcopy \\10.96.192.242\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.96.243."
IF NOT errorlevel 1 start /min xcopy \\10.96.243.243\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.96.193."
IF NOT errorlevel 1 start /min xcopy \\10.96.193.242\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.96.215."
IF NOT errorlevel 1 start /min xcopy \\10.96.215.242\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.64.175."
IF NOT errorlevel 1 start /min xcopy \\10.64.175.243\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.96.253."
IF NOT errorlevel 1 start /min xcopy \\10.96.253.243\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.96.231."
IF NOT errorlevel 1 start /min xcopy \\10.96.231.242\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.64.235."
IF NOT errorlevel 1 start /min xcopy \\10.64.235.243\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.96.254."
IF NOT errorlevel 1 start /min xcopy \\10.96.254.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.96.196."
IF NOT errorlevel 1 start /min xcopy \\10.96.196.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.41.247."
IF NOT errorlevel 1 start /min xcopy \\10.41.247.242\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.41.246."
IF NOT errorlevel 1 start /min xcopy \\10.41.246.242\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.64.167."
IF NOT errorlevel 1 start /min xcopy \\10.64.167.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.64.239."
IF NOT errorlevel 1 start /min xcopy \\10.64.239.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.64.249."
IF NOT errorlevel 1 start /min xcopy \\10.64.249.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.128.240."
IF NOT errorlevel 1 start /min xcopy \\10.128.240.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.128.212."
IF NOT errorlevel 1 start /min xcopy \\10.128.212.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.128.244."
IF NOT errorlevel 1 start /min xcopy \\10.128.244.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.128.244."
IF NOT errorlevel 1 start /min xcopy \\10.128.244.219\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.128.144."
IF NOT errorlevel 1 start /min xcopy \\10.128.144.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.46.180."
IF NOT errorlevel 1 start /min xcopy \\10.46.180.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.46.232."
IF NOT errorlevel 1 start /min xcopy \\10.46.232.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.46.232."
IF NOT errorlevel 1 start /min xcopy \\10.46.232.219\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.46.236."
IF NOT errorlevel 1 start /min xcopy \\10.46.236.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.41.247."
IF NOT errorlevel 1 start /min xcopy \\10.41.247.245\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.41.247."
IF NOT errorlevel 1 start /min xcopy \\10.41.247.244\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.64.176."
IF NOT errorlevel 1 start /min xcopy \\10.64.176.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.64.227."
IF NOT errorlevel 1 start /min xcopy \\10.64.227.210\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.64.227."
IF NOT errorlevel 1 start /min xcopy \\10.64.227.209\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.64.218."
IF NOT errorlevel 1 start /min xcopy \\10.64.218.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.64.252."
IF NOT errorlevel 1 start /min xcopy \\10.64.252.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.64.132."
IF NOT errorlevel 1 start /min xcopy \\10.64.132.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.64.132."
IF NOT errorlevel 1 start /min xcopy \\10.64.132.219\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.46.239."
IF NOT errorlevel 1 start /min xcopy \\10.46.239.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.131.51."
IF NOT errorlevel 1 start /min xcopy \\10.131.51.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.43.250."
IF NOT errorlevel 1 start /min xcopy \\10.43.250.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.43.250."
IF NOT errorlevel 1 start /min xcopy \\10.43.250.219\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.96.194."
IF NOT errorlevel 1 start /min xcopy \\10.96.194.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.42.253."
IF NOT errorlevel 1 start /min xcopy \\10.42.253.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.42.239."
IF NOT errorlevel 1 start /min xcopy \\10.42.239.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.42.239."
IF NOT errorlevel 1 start /min xcopy \\10.42.239.219\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.96.225."
IF NOT errorlevel 1 start /min xcopy \\10.96.225.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.96.235."
IF NOT errorlevel 1 start /min xcopy \\10.96.235.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.96.235."
IF NOT errorlevel 1 start /min xcopy \\10.96.235.219\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.96.153."
IF NOT errorlevel 1 start /min xcopy \\10.96.153.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.96.206."
IF NOT errorlevel 1 start /min xcopy \\10.96.206.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.96.206."
IF NOT errorlevel 1 start /min xcopy \\10.96.206.219\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.96.152."
IF NOT errorlevel 1 start /min xcopy \\10.96.152.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.96.152."
IF NOT errorlevel 1 start /min xcopy \\10.96.152.219\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.96.227."
IF NOT errorlevel 1 start /min xcopy \\10.96.227.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.96.236."
IF NOT errorlevel 1 start /min xcopy \\10.96.236.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.41.246."
IF NOT errorlevel 1 start /min xcopy \\10.41.246.245\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.41.246."
IF NOT errorlevel 1 start /min xcopy \\10.41.246.244\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.46.233."
IF NOT errorlevel 1 start /min xcopy \\10.46.233.107\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.64.220."
IF NOT errorlevel 1 start /min xcopy \\10.64.220.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.96.202."
IF NOT errorlevel 1 start /min xcopy \\10.96.202.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.64.146."
IF NOT errorlevel 1 start /min xcopy \\10.64.146.210\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.64.146."
IF NOT errorlevel 1 start /min xcopy \\10.64.146.209\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.96.149."
IF NOT errorlevel 1 start /min xcopy \\10.96.149.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.96.231."
IF NOT errorlevel 1 start /min xcopy \\10.96.231.245\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.96.231."
IF NOT errorlevel 1 start /min xcopy \\10.96.231.244\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.96.231."
IF NOT errorlevel 1 start /min xcopy \\10.96.231.243\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.64.216."
IF NOT errorlevel 1 start /min xcopy \\10.64.216.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.69.43."
IF NOT errorlevel 1 start /min xcopy \\10.69.43.150\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.64.236."
IF NOT errorlevel 1 start /min xcopy \\10.64.236.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.64.205."
IF NOT errorlevel 1 start /min xcopy \\10.64.205.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.69.43."
IF NOT errorlevel 1 start /min xcopy \\10.69.43.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.46.241."
IF NOT errorlevel 1 start /min xcopy \\10.46.241.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.64.251."
IF NOT errorlevel 1 start /min xcopy \\10.64.251.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.96.251."
IF NOT errorlevel 1 start /min xcopy \\10.96.251.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.64.238."
IF NOT errorlevel 1 start /min xcopy \\10.64.238.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.41.1."
IF NOT errorlevel 1 start /min xcopy \\10.41.1.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.96.237."
IF NOT errorlevel 1 start /min xcopy \\10.96.237.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.97.4."
IF NOT errorlevel 1 start /min xcopy \\10.97.4.250\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.131.131."
IF NOT errorlevel 1 start /min xcopy \\10.131.131.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.96.150."
IF NOT errorlevel 1 start /min xcopy \\10.96.150.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.128.245."
IF NOT errorlevel 1 start /min xcopy \\10.128.245.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.128.250."
IF NOT errorlevel 1 start /min xcopy \\10.128.250.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.128.248."
IF NOT errorlevel 1 start /min xcopy \\10.128.248.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.46.230."
IF NOT errorlevel 1 start /min xcopy \\10.46.230.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.96.238."
IF NOT errorlevel 1 start /min xcopy \\10.96.238.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.128.211."
IF NOT errorlevel 1 start /min xcopy \\10.128.211.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.46.238."
IF NOT errorlevel 1 start /min xcopy \\10.46.238.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.96.234."
IF NOT errorlevel 1 start /min xcopy \\10.96.234.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.64.234."
IF NOT errorlevel 1 start /min xcopy \\10.64.234.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.96.223."
IF NOT errorlevel 1 start /min xcopy \\10.96.223.220\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "10.96.232."
IF NOT errorlevel 1 start /min xcopy \\10.96.232.50\distribution\*.* c:\rainmeter\ /E /Y /Q
ipconfig | find /i "196.14.34."
IF NOT errorlevel 1 start /min xcopy \\196.14.34.107\distribution\*.* c:\rainmeter\ /E /Y /Q
PING 1.1.1.1 -n 1 -w 5000 >NUL

:CPLUS
Echo off 
Reg Query HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\ | find "11.0"
IF NOT errorlevel 1 goto STARTBAC

Reg Query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\VisualStudio\ | find "11.0"
IF NOT errorlevel 1 goto STARTBAC

CLS
ECHO  BBBBBBBB    IIIIIIIII  DDDDDDD   V           V   EEEEEEEEE  SSSSSSSSS  TTTTTTTTTT 
ECHO  B       B      II      D      D   V         V    E          S              TT
ECHO  B       B      II      D       D   V       V     E          S              TT
ECHO  B BBBBBB       II      D       D    V     V      EEEEE      SSSSSSSSS      TT
ECHO  B       B      II      D       D     V   V       E                  S      TT
ECHO  B       B      II      D      D       V V        E                  S      TT
ECHO  BBBBBBBB    IIIIIIIII  DDDDDDD         V         EEEEEEEEE  SSSSSSSSS      TT
ECHO 2 
ECHO               AA        U       U    TTTTTTTTTTTTT     OOOOOOOO
ECHO             A    A      U       U          TT         O        O
ECHO            A      A     U       U          TT         O        O
ECHO            AAAAAAAA     U       U          TT         O        O
ECHO           A        A    U       U          TT         O        O 
ECHO           A        A    U       U          TT         O        O
ECHO           A        A     UUUUUUU           TT          OOOOOOOO
Echo .
Echo .
Echo .   Bidvest Automotive IT is now installing the new Desktop Communicator
Echo .             
Echo .                         ---------------------- 
Echo .                           Click YES if asked 
Echo .                         ----------------------
PING 1.1.1.1 -n 1 -w 2000 >NUL
Echo .                         ---------------------- 
Echo .                           Click YES if asked 
Echo .                         ----------------------
PING 1.1.1.1 -n 1 -w 2000 >NUL
Echo .                          
Echo .

cd c:\rainmeter\

vcredist_x86.exe /passive

SET /A XCOUNT+=1

PING 1.1.1.1 -n 1 -w 5000 >NUL

Reg Query HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\ | find "11.0"
IF NOT errorlevel 1 goto STARTBAC

Reg Query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\VisualStudio\ | find "11.0"
IF NOT errorlevel 1 goto STARTBAC

IF "%XCOUNT%" == "3" GOTO end
GOTO CPLUS

Exit

:STARTBAC
Echo off 
Start /min \\mccarthyltd.local\netlogon\rainupdate.bat
PING 1.1.1.1 -n 1 -w 5000 >NUL

start c:\rainmeter\rainmeter\rainmeter.exe
echo %ComputerName% %date% %time% raindist>>\\196.14.34.107\distribution\checkin\%computername%.txt
exit

:end
echo %ComputerName% %date% %time% raindist1 FAILED >>\\196.14.34.107\distribution\FAILED\%computername%.txt
Exit