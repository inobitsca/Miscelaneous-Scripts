@echo off
CLS
SETLOCAL EnableDelayedExpansion
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set "DEL=%%a"
)

setlocal
:PROMPT
echo(
echo(
echo(
echo(

call :ColorText E0 "Bidvest Automotive IT needs to install software on your computer."
echo(
PING 1.1.1.1 -n 1 -w 500 >NUL
call :ColorText f0 "                It May be neccessary to reboot................. "
echo(
PING 1.1.1.1 -n 1 -w 500 >NUL
echo(
call :ColorText 0a "Press Y if we can go ahead now."
echo(
PING 1.1.1.1 -n 1 -w 500 >NUL
call :ColorText 0b "Press D to delay 10 minutes"
echo(
PING 1.1.1.1 -n 1 -w 500 >NUL
call :ColorText 0c "Press N to cancel"
echo(
PING 1.1.1.1 -n 1 -w 500 >NUL
SET /P AREYOUSURE=(Y/D/[N])?
IF /I "%AREYOUSURE%" EQU "N" GOTO END
IF /I "%AREYOUSURE%" EQU "D" GOTO Delay
IF /I "%AREYOUSURE%" EQU "Y" GOTO Start
Goto End
:Start
echo(
echo(
call :ColorText 0a "Thanks. We are installing software."
echo(
echo(
call :ColorText 0a "Please accept any prompts that appear."
PING 1.1.1.1 -n 1 -w 2000 >NUL

goto :eof

:ColorText
echo off
<nul set /p ".=%DEL%" > "%~2"
findstr /v /a:%1 /R "^$" "%~2" nul
del "%~2" > nul 2>&1
goto :eof

:Delay
echo(
echo(
call :ColorText b0 "Thanks. We will wait 10 minutes."
PING 1.1.1.1 -n 1 -w 2000 >NUL
goto :eof

:End
echo(
echo(
call :ColorText 0b "Thanks. We will try again later."
PING 1.1.1.1 -n 1 -w 2000 >NUL
