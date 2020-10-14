echo off
set /a num=%random% %%20000 +1000
echo %num%
echo on
PING 1.1.1.1 -n 1 -w %num% >NUL