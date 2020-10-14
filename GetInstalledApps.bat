@echo off
c:
cd\
cd %userprofile%\desktop
echo List of softwares > temp3.txt
echo ================= >> temp3.txt
reg export HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall temp1.txt
find "DisplayName" temp1.txt| find /V "ParentDisplayName" > temp2.txt
for /f "tokens=2,3 delims==" %%a in (temp2.txt) do (echo %%a >> temp3.txt)
erase temp1.txt
erase temp2.txt
@echo off > SoftwareList.txt & setLocal enableDELAYedeXpansion
set Q="

for /f "tokens=* delims= " %%a in (temp3.txt) do (
set S=%%a
set S=!S:"=!
>> SoftwareList.txt echo.!S!
)
erase temp3.txt
notepad SoftwareList.txt