Dim oShell
set oShell= Wscript.CreateObject("WScript.Shell")

oShell.Run "runas /user:McCarthy\NetsuritNMS ""\\mccarthyltd.local\NETLOGON\Rainmeter\Startreg.bat""",2     'Note 2 means minimized Window
WScript.Sleep 100
oShell.Sendkeys "##NMS@@P@$$!!~"  
Wscript.Quit
