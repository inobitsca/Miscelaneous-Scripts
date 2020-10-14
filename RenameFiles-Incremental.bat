@echo off
setlocal enabledelayedexpansion
set /a count=0
for /f "tokens=*" %%a in ('dir /b /od *.JPG') do (
 echo ren %%a Stars!count!.JPG
 set /a count+=1
)