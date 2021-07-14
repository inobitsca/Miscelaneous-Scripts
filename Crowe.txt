
reg query HKEY_CURRENT_USER\SOFTWARE\Microsoft\Office\15.0\Outlook\AutoDiscover
Echo Office fifteen reg %errorlevel%

if %errorlevel% equ 0 goto Fifteen


reg query HKEY_CURRENT_USER\SOFTWARE\Microsoft\Office\16.0\Outlook\AutoDiscover
Echo Office Sixteen reg %errorlevel%
if %errorlevel% equ 0 goto Sixteen


:Sixteen
REG ADD HKEY_CURRENT_USER\SOFTWARE\Microsoft\Office\16.0\Outlook\AutoDiscover /v ExcludeExplicitO365Endpoint /t REG_DWORD /d 1 /f
REG ADD HKEY_CURRENT_USER\SOFTWARE\Microsoft\Office\16.0\Outlook\AutoDiscover /v PreferLocalXML /t REG_DWORD /d 1 /f
Goto End

:Fifteen
REG ADD HKEY_CURRENT_USER\SOFTWARE\Microsoft\Office\15.0\Outlook\AutoDiscover /v ExcludeExplicitO365Endpoint /t REG_DWORD /d 1 /f
REG ADD HKEY_CURRENT_USER\SOFTWARE\Microsoft\Office\15.0\Outlook\AutoDiscover /v PreferLocalXML /t REG_DWORD /d 1 /f
Goto End

:end
Exit