echo off
c:
cd c:\AppV\
cls
reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\AppV\ | find "Client"
IF NOT errorlevel 1 Goto Client
                           
COLOR 0C
Echo .                    Bidvest Automotive Software Update

:PROMPT
CLS
echo(
echo(
echo(
echo(
echo(
echo(
echo(
echo(
COLOR E0
Echo ____________________________Bidvest Automotive IT ____________________________
echo(
Echo ______________ We need to install or update software on your computer_________
echo(
echo(
echo(
PING 1.1.1.1 -n 1 -w 1500 >NUL
Color f0 
Echo __________________It May be neccessary to reboot your computer__________________
echo(
:PROMPT2
echo(
PING 1.1.1.1 -n 1 -w 1500 >NUL
COLOR E0
echo(
Echo "Press Y if we can go ahead now."
echo(
PING 1.1.1.1 -n 1 -w 1000 >NUL
echo "Press D to delay 10 minutes"
echo(
PING 1.1.1.1 -n 1 -w 1000 >NUL
Echo "Press N to cancel"
echo(
PING 1.1.1.1 -n 1 -w 1000 >NUL
SET /P AREYOUSURE=(Y/D/[N])?
IF /I "%AREYOUSURE%" EQU "N" GOTO END
IF /I "%AREYOUSURE%" EQU "D" GOTO Delay
IF /I "%AREYOUSURE%" EQU "Y" GOTO Start

CLS
COLOR 0C
Echo "That is not a valid choice."
PING 1.1.1.1 -n 1 -w 2000 >NUL
cls
Echo Bidvest Automotive IT needs to install software on your computer.
Goto Prompt2

:Start
CLS
echo(
echo(
Color 0a 
Echo -------------------Thanks. We are installing software.-------------------
PING 1.1.1.1 -n 1 -w 1000 >NUL
echo(
echo(
Echo -------------------Please accept any prompts that appear.-------------------
PING 1.1.1.1 -n 1 -w 7000 >NUL

Elevate "\\mccarthyltd.local\netlogon\AppV\AppVCheck.bat"

PING 1.1.1.1 -n 1 -w 3000 >NUL

Exit


:Delay
CLS
echo(
echo(
Color b0 
Echo Thanks. We will ask again in 10 minutes.
PING 1.1.1.1 -n 1 -w 5000 >NUL
wscript.exe "C:\AppV\invisible.vbs" "C:\AppV\wait10.bat"
REM goto :eof
Exit

:End
CLS
echo(
echo(
Color 0c 
Echo Thanks. We will try again later.
PING 1.1.1.1 -n 1 -w 5000 >NUL
Exit

:Client

CLS
echo(
echo(
Color 0a 
Echo -----------------Thank You. We have installed the software.-----------------
echo(
echo(
Echo -----------------   We need to cleanup temporary files.    -----------------
PING 1.1.1.1 -n 1 -w 1000 >NUL
echo(
echo(
Echo -------------------Please accept any prompts that appear.-------------------
PING 1.1.1.1 -n 1 -w 3000 >NUL
elevate \\mccarthyltd.local\NETLOGON\AppV\Cleanup.bat
Exit
