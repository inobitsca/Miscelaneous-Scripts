echo off
REM Dir C:\rainmeter\rainmeter\ | find /i "Rainmeter.exe"
REM IF NOT errorlevel 1 GOTO Reg
REM Goto End

:Reg
reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\ | find /i "Rainmeter.exe"
IF NOT errorlevel 1 Goto End

:RegAdd

Echo on
reg import \\mccarthyltd.local\NETLOGON\Rainmeter\rainstart.reg

Echo off

:End
Echo The End!
Exit