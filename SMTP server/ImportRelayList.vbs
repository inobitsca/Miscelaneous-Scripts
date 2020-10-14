''''''''''''''''''''''''''''''''``VERSION 1.0``'''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'         Script to Import a bunch of IP addresses to the ReplayIpList             '
'                                                                                  '
'                             (c)vijaysk@microsoft.com                             '
'                             blogs.msdn.com/vijaysk                               '
'                                                                                  '
'                                                                                  '
'         USAGE : cscript ImportRelayList.vbs                                      '
'         PREREQUISITE : This script needs ip.txt in the same folder.              '
'         Store your IP addresses in ip.txt FORMAT: Each line should be IP,MASK    '
'                                                                                  '
'                                                                                  '
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit
Dim objSMTP,objRelayIpList,objCurrentList,objIP,objFSO,objTextFile,count,newIpList(),inputOption
Set objSMTP = GetObject("IIS://localhost/smtpsvc/1")
Set objRelayIpList = objSMTP.Get("RelayIpList") 
'objRelayIpList is of type IIsIPSecuritySetting http://msdn.microsoft.com/en-us/library/ms525725.aspx
Wscript.Echo "============================================" 
Wscript.Echo "CURRENT SETTINGS"
Wscript.Echo "================"
Wscript.Echo " " 
Wscript.Echo "Computer(s) that may relay through this virtual server."
Wscript.Echo " " 
' GrantByDefault returns 0 when "only the list below" is set (false) and -1 when all except the list below is set(true)
If objRelayIpList.GrantByDefault = true Then
    Wscript.Echo "All except the list below :"
    objCurrentList = objRelayIpList.IPDeny
Else 
    Wscript.Echo "Only the list below :"
    objCurrentList = objRelayIpList.IPGrant
End If
count = 0
For Each objIP in objCurrentList
        Wscript.Echo objIP 
        count = count + 1
Next
If count = 0 Then
    Wscript.Echo "*NIL*"
End If
Wscript.Echo "============================================" 
Wscript.Echo " " 
Wscript.Echo "Replacing ReplayIpList with the IP address(es) from the ip.txt file."
Wscript.Echo " "
Do While Not((inputOption = "a") Or (inputOption = "d") Or (inputOption = "x") ) 
Wscript.Echo "ENTER " 
Wscript.Echo "A to add to Allow List (Only the list below)"
Wscript.Echo "D to add to Deny List (All except the list below)"
Wscript.Echo "X Exit without making changes"
Wscript.Echo " "
inputOption = lcase(trim(Wscript.StdIn.ReadLine))
Loop
Set objFSO = CreateObject("Scripting.FileSystemObject")
If objFSO.FileExists("ip.txt") Then
    Set objTextFile = objFSO.OpenTextFile("ip.txt",1)

    count = 0
    Do Until objTextFile.AtEndOfStream
        Redim Preserve newIpList(count)
        newIpList(count) = objTextFile.Readline
        count = count + 1
    Loop
    objTextFile.Close

    'For each objIP in newIpList
    '    Wscript.Echo objIP
    'Next
    Wscript.Echo " "
    Select Case inputOption
        Case "a"
            objRelayIpList.GrantByDefault = false
            objRelayIpList.IpGrant = newIpList
            Wscript.Echo "SET " & count &" address(es) to Allow List"        
        Case "d"
            objRelayIpList.GrantByDefault = true
            objRelayIpList.IpDeny = newIpList
            Wscript.Echo "SET " & count &" address(es) to Deny List"
        Case "x"
            Wscript.Echo "Exiting without making changes"
            Wscript.Echo "============================================" 
            Wscript.Quit
    End Select
    
    objSMTP.Put "RelayIpList",objRelayIpList
    objSMTP.SetInfo
    Wscript.Echo " "
    
    Wscript.Echo "============================================" 
Else
    Wscript.Echo "Please create a file ip.txt that contains the list of IP address(es)"
    Wscript.Echo "FORMAT : Each Line should be IP,MASK "
    Wscript.Echo "EX     : 127.0.0.1,255.255.255.255"
End If
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'         Script to Import a bunch of IP addresses to the ReplayIpList             '
'                                                                                  '
'                             (c)vijaysk@microsoft.com                             '
'                             blogs.msdn.com/vijaysk                               '
'                                                                                  '
'                                                                                  '
'         USAGE : cscript ImportRelayList.vbs                                      '
'         PREREQUISITE : This script needs ip.txt in the same folder.              '
'         Store your IP addresses in ip.txt FORMAT: Each line should be IP,MASK    '
'                                                                                  '
'                                                                                  '
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''