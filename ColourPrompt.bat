@echo off
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

call :ColorText F0 "We need to install software and reboot."
echo(
echo(
call :ColorText eC "Are you sure"
SET /P AREYOUSURE=(Y/[N])?
IF /I "%AREYOUSURE%" NEQ "Y" GOTO END
echo(
echo(
call :ColorText 0a "Thanks. We are installing software."
echo(
echo(
call :ColorText 0a "Please accept any prompts that appear."



goto :eof

:ColorText
echo off
<nul set /p ".=%DEL%" > "%~2"
findstr /v /a:%1 /R "^$" "%~2" nul
del "%~2" > nul 2>&1
goto :eof

:End
echo(
echo(
call :ColorText 0b "Thanks. We will try again later."
