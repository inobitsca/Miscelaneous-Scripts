Const HKEY_LOCAL_MACHINE = &H80000002
strComputer = "."
Set objReg = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & _
 strComputer & "\root\default:StdRegProv")
 
strKeyPath = "SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
objReg.EnumKey HKEY_LOCAL_MACHINE, strKeyPath, arrSubKeys
For Each Subkey in arrSubKeys
 If LCase(Right(Subkey, 4)) = ".bak" Then    
    DeleteSubkeys HKEY_LOCAL_MACHINE, strKeyPath & "\" & SubKey
 End If
Next
Sub DeleteSubkeys(HKEY, strKeyPath) 
    objReg.EnumKey HKEY, strKeyPath, arrSubkeys 
    If IsArray(arrSubkeys) Then 
        For Each strSubkey In arrSubkeys 
            DeleteSubkeys HKEY, strKeyPath & "\" & strSubkey
        Next 
    End If 
    objReg.DeleteKey HKEY, strKeyPath 
End Sub