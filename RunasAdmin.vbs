Dim oShell
set oShell= Wscript.CreateObject("WScript.Shell")

oShell.Run "runas /user:esp\cedrica cmd.exe"    'Note 2 means minimized Window
WScript.Sleep 1000
oShell.Sendkeys "Infinity5"  
Wscript.Quit
