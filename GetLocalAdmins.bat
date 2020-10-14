@echo off
SetLocal EnableDelayedExpansion
title Local admin audit (C)Matt Savige
Echo **********************************************************************
echo *                                                                    *
echo *         Local Admin Audit                                          *
echo *        Written 2009 by Matthew Savige                              *
echo * __________________________________________________________________ *
echo * Note: This script requires systernals psexec to be either in the   *
echo *       same directory, or set in the path variable                  *
echo * __________________________________________________________________ *
echo **********************************************************************
set OF=CON
if not "%3"=="" set OF=%3
if "%1"=="net" GOTO NET
if "%1"=="host" GOTO HOST
if "%1"=="file" GOTO FILE

echo Usage:
echo Syntax: localadmins mode ip {output file}
echo .
echo Modes:
echo net    Specifies the ip range to be a subnet. Must be class C. 
echo host   Specifies the ip to be a single host
echo file   Specifies the ip to be read from a txt file. (one IP per line. Extra information will be given if the file is taken from MS DHCP export)
echo.
Echo ip:
echo net    Specifies the starting IP Address
echo host   Specifies the IP address to scan
echo file   Specifies the file to read IPs from

goto EOF

:host
echo ******************************************************************** >> %OF%
psexec \\%2 hostname 2>NUL 1>>%OF%
psexec \\%2 net localgroup administrators 2>NUL 1>>%OF%
echo ******************************************************************** >> %OF%
GOTO EOF
:FILE
echo IP Range taken from %2
if not "%OF%"=="CON" echo IP range taken from %2 > %OF%

for /f "tokens=1-3 delims=	" %%i in (%2) do (
echo.
if not "%OF%"=="CON" echo. >> %OF%
ping /n 1 %%i >nul
rem echo errorlevel !errorlevel!
if !errorlevel! == 0 echo %%i - UP
if not !errorlevel! == 0 echo %%i - Down 
if not !errorlevel! == 0 if not "%OF%"=="CON" echo %%i >> %OF%
if not !errorlevel! == 0 if not "%%j"=="" echo Host:%%j expires: %%k
if not !errorlevel! == 0 if not "%OF%"=="CON" if not "%%j"=="" echo Down Host:%%j expires: %%k >> %OF%
if !errorlevel! == 0 if not "%OF%"=="CON" echo %%i - UP >> %OF%
if !errorlevel! == 0 echo ******************************************************************** >> %OF%

rem color 01
if !errorlevel! == 0 psexec -n 5 \\%%i hostname 2>NUL 1>>%OF%
rem color 02
if !errorlevel! == 0 psexec -n 5 \\%%i net localgroup administrators 2>NUL 1>>%OF%
if !errorlevel! == 0 echo ******************************************************************** >> %OF%
:1
rem color 08
)
goto eof

:NET
for /f "tokens=1-3 delims=." %%i in ('echo %2') do @set IP=%%i.%%j.%%k
for /f "tokens=4 delims=." %%i in ('echo %2') do @set start=%%i

echo IP Range: %IP%.%start%-254

if not "%OF%"=="CON" echo IP Range: %IP%.%start%-254 >> %OF%

for /L %%i in (%start%,1,254) do (
ping /n 1 %IP%.%%i >nul
rem echo errorlevel !errorlevel!
if !errorlevel! == 0 echo %IP%.%%i - UP
if not !errorlevel! == 0 echo %IP%.%%i - Down
if not !errorlevel! == 0 if not "%OF%"=="CON" echo %IP%.%%i - Down >> %OF%
if !errorlevel! == 0 if not "%OF%"=="CON" echo %IP%.%%i - UP >> %OF%
if !errorlevel! == 0 echo ******************************************************************** >> %OF%

rem color 01
if !errorlevel! == 0 psexec -n 5 \\%IP%.%%i hostname 2>NUL 1>>%OF%
rem color 02
if !errorlevel! == 0 psexec -n 5 \\%IP%.%%i net localgroup administrators 2>NUL 1>>%OF%
if !errorlevel! == 0 echo ******************************************************************** >> %OF%
:1
rem color 08
)

:EOF 
EndLocal