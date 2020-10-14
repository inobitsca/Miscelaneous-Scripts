option explicit

Dim oShell
Set oShell = CreateObject("WScript.Shell")

oShell.run "cmd.exe"

WScript.Sleep 500

oShell.SendKeys "runas /user:esp\cedrica ""cmd.exe""",2
oShell.SendKeys ("{Enter}")

WScript.Sleep 500

oShell.SendKeys "Infinity5"
oShell.SendKeys ("{Enter}")

oShell.SendKeys "e:\scripts\runas3.vbs"
oShell.SendKeys ("{Enter}")

'oShell.SendKeys "Exit"
'oShell.SendKeys ("{Enter}")

Wscript.Quit