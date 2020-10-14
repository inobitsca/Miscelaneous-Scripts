'=====================
'= Gets Local Admins =
'=====================
Sub GetLocalAdmins (Computer)
Dim objComp
strComputer = Computer
Set objComp = GetObject("WinNT://" & strComputer) 'seems to have issues here.
objComp.GetInfo 'or here....
If objComp.PropertyCount > 0 Then
  Set objGroup = GetObject("WinNT://" & strComputer & "/Administrators,group")
  If objGroup.PropertyCount > 0 Then
    WScript.Echo "The members of the local Administrators group on " & strComputer & " 

are:"
    For Each mem In objGroup.Members
      WScript.echo vbTab & Right(mem.adsPath,Len(mem.adsPath) - 8)
    Next
  Else
    WScript.echo "** Connecting to the local Administrators group on " & strComputer & " 

failed."
    WScript.Quit 1
  End If
Else
  WScript.Echo "** Connecting to " & strComputer & " failed."
  WScript.Quit 1
End If
End Sub
or just use the following command from batch:

net localgroup administrators