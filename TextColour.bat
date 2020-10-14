@echo off
SETLOCAL EnableDelayedExpansion
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set "DEL=%%a"
)
echo say the name of the colors, don't read

call :ColorText 0a "Green"
echo(
call :ColorText eC "Red"
echo(
call :ColorText 0b "Turquoise"
echo(
call :ColorText 09 "Blue"
echo(
call :ColorText 0F "White"
echo(
call :ColorText 0e "Yellow"


goto :eof

:ColorText
echo off
<nul set /p ".=%DEL%" > "%~2"
findstr /v /a:%1 /R "^$" "%~2" nul
del "%~2" > nul 2>&1
goto :eof