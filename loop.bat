#
echo off
SET /A XCOUNT=1
:loop
CLS
SET /A XCOUNT-=1
ping 10.1.27.%XCOUNT% -n 1 -w 100 
IF "%XCOUNT%" == "254" GOTO end
  GOTO loop

:end