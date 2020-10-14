'
' Author            Paul Bergson       Duluth, Mn
' Date Written      January 2006
' Description       Rips out all Computers and their context from AD and writes them to a csv file
'
'
'                                              This may be reused as long as you don't remove my name or sell it
' Modified by		Sheen Austin	(May, 2009)
' Features Added	Query Email Address, Exchange Home Server.
'

Option Explicit

Dim aryContainer(500)       	' Track the name of all containers
Dim aryCN(9999,10)          	' Track the name of all users
Dim aryWhen()               	' When Created
Dim arySvCN()               	' Original context
Dim aryHomeDirectory()      	' Location of home folder
Dim aryScriptPath()         	' Location of script path
Dim arydisplayName()        	' Display Name
Dim arymail()	    	    	' Email Address
Dim arymsExchHomeServerName () 	'Exchange Home Server
Dim cntLen, cntComma, cntRight
Dim cntX, cntY, cntZ
Dim cntL, cntM, cntO
Dim cntColumns
Dim flgLoop
Dim flgContainerFnd
Dim txtName, txtCN, txtSvName, tmpName
Dim usr
Dim flag
Dim objConnection
Dim objRecordSet
Dim objCommand
Dim objComputer
Dim fso
Dim ts
Dim strHomeDirectory
Dim Output
Dim WshNetwork
Dim strDomainName                             ' NetBIOS Domain Name

Dim fsoHTA
Dim tsHTA
Dim CurrentDate
Dim MonthDate
Dim DayDate
Dim YearDate
Dim FileDate
Dim exFlg                   ' Exchange Object flag
Dim arrDomLevels
Dim LDAPADsPath
Dim LDAPStart
Dim cntDropHost

Dim oRoot, sConfig, oConnection, oCommand, sQuery
Dim oResults, oDC, sDNSDomain, oShell, nBiasKey
Dim nBias, k, sDCs(), sAdsPath, oDate, nDate
Dim oComputer, nLatestDate

Const FileLocation =  ".\"    ' Define the starting location of where you want to store the csv

Const ADS_UF_PASSWD_NOTREQD = &H0020
Const ADS_UF_DONT_EXPIRE_PASSWD = &H10000
Const ADS_UF_PASSWORD_EXPIRED = &H800000
Const ADS_UF_ACCOUNTDISABLE = &H0002

' Find all defined DC's in the domain
Sub AvailableDCs

' Obtain local Time Zone bias from machine registry.
' Watch for line wrapping.
Set oShell = CreateObject("Wscript.Shell")
nBiasKey =  oShell.RegRead("HKLM\System\CurrentControlSet\Control\TimeZoneInformation\ActiveTimeBias")
If UCase(TypeName(nBiasKey)) = "LONG" Then
  nBias = nBiasKey
ElseIf UCase(TypeName(nBiasKey)) = "VARIANT()" Then
  nBias = 0
  For k = 0 To UBound(nBiasKey)
    nBias = nBias + (nBiasKey(k) * 256^k)
  Next
End If

' Determine configuration context and
' DNS domain from RootDSE object.
Set oRoot = GetObject("LDAP://RootDSE")
sConfig = oRoot.Get("ConfigurationNamingContext")
sDNSDomain = oRoot.Get("DefaultNamingContext")

' Use ADO to search Active Directory for
' ObjectClass nTDSDSA.
' This will identify all Domain Controllers.
Set oCommand = CreateObject("ADODB.Command")
Set oConnection = CreateObject("ADODB.Connection")
oConnection.Provider = "ADsDSOObject"
oConnection.Open = "Active Directory Provider"
oCommand.ActiveConnection = oConnection

sQuery = "<LDAP://" & sConfig _
  & ">;(ObjectClass=nTDSDSA);AdsPath;subtree"

oCommand.CommandText = sQuery
oCommand.Properties("Page Size") = 100
oCommand.Properties("Timeout") = 30
oCommand.Properties("Searchscope") = 2
oCommand.Properties("Cache Results") = False

Set oResults = oCommand.Execute

' Enumerate parent objects of class nTDSDSA. Save
' Domain Controller names in dynamic array sDCs.
k = 0
'
''''' Time to find out the actual DC names, verify if online and if so save them to an array
'
Do Until oResults.EOF
  Set oDC = _
    GetObject(GetObject(oResults.Fields("AdsPath")).Parent)

    On Error Resume Next
    Set oComputer = GetObject("LDAP://" & oDC.DNSHostName)   ' Attach to see if DC is available

    if CStr(Err.Number) = 0 then     ' if no error then the DC exists
       ReDim Preserve sDCs(k)
       sDCs(k) = oDC.DNSHostName
       k = k + 1
     end if
  oResults.MoveNext
Loop

cntDropHost = inStr(sDCs(0),".") + 1                                     ' Find the start of the domain name
LDAPStart = Mid(sDCs(0),cntDropHost,(Len(sDCs(0))-cntDropHost+1))      ' Drop the host name

arrDomLevels = Split(LDAPStart, ".")                  ' Convert to LDAP Path (dc=yourdomain,dc=com...)
LDAPADsPath = "dc=" & Join(arrDomLevels, ",dc=")

'  Find The NetBIOS Name of the domain

Set WshNetwork = WScript.CreateObject("WScript.Network")
strDomainName = WshNetwork.UserDomain                     ' Store the Domain Name

End Sub

'
''''' Find out the last time on each DC
'
Sub LastTime

' Hard code LDAP AdsPath of Computer.
sAdsPath = arySvCN(cntL)

' Retrieve LastLogon attribute for computer on
' each Domain Controller.
nLatestDate = #1/1/1601#
oDate = #1/1/1601#

For k = 0 To Ubound(sDCs)

  On Error Resume Next
  Set oComputer = GetObject("LDAP://" & sDCs(k) & "/" & sAdsPath)

' Trap error in case LastLogon is null.
  Set oDate = oComputer.LastLogon
  On Error Resume Next

  If Err.Number <> 0 Then
    Err.Clear
    nDate = #1/1/1601#
  Else
    If (oDate.HighPart = 0) And (oDate.LowPart = 0 ) Then
      nDate = #1/1/1601#
    Else
      nDate = #1/1/1601# + (((oDate.HighPart * (2 ^ 32)) _
        + oDate.LowPart)/600000000 - nBias)/1440
    End If
  End If

  Err.Clear
  If nDate > nLatestDate Then
    nLatestDate = nDate
  End If

Next

End Sub

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Routine to strip out all containers and place in the aryContainer '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub Stripper

Do
    cntLen = Len(txtName)-3
    cntComma = Instr(txtName,",") - 1               ' Find the end of the name

    If cntComma < 0 Then                            ' Last Name to process there is no comma
       cntComma = Len(txtName)
    End If

    
    flgContainerFnd = "N"


    For cntL = 0 to 500                             ' Does this current Container exist?
       If aryContainer(cntL) = "" Then              ' If current location is blank then add it to the table
          aryContainer(cntL) = txtCN
          Exit For
       End If

       If aryContainer(cntL) = txtCN Then           ' OU found
          Exit For
       End if
    Next

    aryCN(cntX, cntY) = cntL                        ' Store location of OU
    cntY = cntY + 1                                 ' increment counter

    cntComma = Instr(txtName,",")                   ' If equal to zero then all done

    If cntComma > 0 Then
       cntRight = Len(txtName) - (cntComma)         ' Get to start of next part of name
       txtName = Right(txtName, cntRight)           ' Purge CN name
       flgLoop = "Y"
    Else
       flgLoop = "N"                                ' Set all done flag
    End If

Loop Until flgLoop = "N"

End Sub


'   This is the start of the program
'
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Main Code of Program                                             '
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''



Call AvailableDCs                                     ' Go get the DC's in the domain

Set objConnection = CreateObject("ADODB.Connection")  ' Create a Connection object in memory
objConnection.Open "Provider=ADsDSOObject;"           ' Open the Connection object using the ADSI OLE DB provider

Set objCommand = CreateObject("ADODB.Command")  'Create an ADO Command object in memory, and assign the Command _
objCommand.ActiveConnection = objConnection     ' object?s ActiveConnection property to the Connection object

objCommand.Properties("Page Size") = 100
objCommand.Properties("Size Limit") = 3000

objCommand.CommandText = _
   "<LDAP://" & LDAPADsPath &  ">;(objectCategory=Computer);sAMAccountName,distinguishedName,name,whenCreated,homeDirectory,scriptPath,displayName,mail,msExchHomeServerName;subtree"

Set objRecordSet = objCommand.Execute            ' Run the query by calling the Execute method of the Command object

cntX = 0
cntY = 0

'
''''' Do an LDAP call and get all Computers in AD and save the Computers data
'
While Not objRecordSet.EOF
    txtName =  lcase(objRecordSet.Fields("distinguishedName"))         ' Access each record in objRecordSet
    txtSvName = txtName

    ReDim Preserve arySvCN(cntX)
    ReDim Preserve aryWhen(cntX)                                ' Save when account created
    ReDim Preserve aryHomeDirectory(cntX)
    ReDim Preserve aryScriptPath(cntX)
    ReDim Preserve arydisplayName(cntX)
    ReDim Preserve arymail(cntX)
    ReDim Preserve arymsExchHomeServerName(cntX)

    aryWhen(cntX)          	  = lcase(objRecordSet.Fields("whenCreated"))
    aryHomeDirectory(cntX) 	  = lcase(objRecordSet.Fields("homeDirectory"))
    aryScriptPath(cntX)    	  = lcase(objRecordSet.Fields("scriptPath"))
    arydisplayName(cntX)   	  = lcase(objRecordSet.Fields("displayName"))
    arymail(cntX)          	  = lcase(objRecordSet.Fields("mail"))
    arymsExchHomeServerName(cntX) = lcase(objRecordSet.Fields("msExchHomeServerName"))

    cntLen = Len(txtName)
    txtName = Left(txtName,(cntLen-18))             ' Provides the name w/o dc=Your Domain,dc=com
    cntLen = Len(txtName)-3
    txtName = Right(txtName,cntLen)                 ' Drops the Container Type Name
    cntComma = Instr(txtName,",") - 1               ' Find the end of the name
    
    aryCN(cntX, cntY) = lcase(objRecordSet.Fields("sAMAccountName"))       ' Save Name
    arySvCN(cntX) = txtSvName                       ' Save Distinguished Name
    cntY = cntY + 1                                 ' increment table counter
    cntRight = Len(txtName) - (cntComma + 1)        ' Get to start of next part of name
    txtName = Right(txtName,cntRight)               ' Purge CN name

    Call Stripper                                   ' Build table of the context of the Computer

    cntX = cntX + 1
    cntY = 0

    objRecordSet.MoveNext			     ' Move to next Computer
Wend

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Create a file using todays date as part of the file name               '
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
CurrentDate = Date
YearDate = Year(CurrentDate)
MonthDate = Month(CurrentDate)
If MonthDate < 9 then
  MonthDate = "0" & MonthDate
End If
DayDate = Day(CurrentDate)
If DayDate < 9 then
  DayDate = "0" & DayDate
End If

FileDate = FileLocation & YearDate & MonthDate & DayDate & "_Computeraccts.csv"

Set fso = CreateObject("Scripting.FileSystemObject")
set ts =  fso.CreateTextFile(FileDate, True)	   ' Create the file

For cntL = 0 to 500                                ' Find out how many columns used
   If aryContainer(cntL) = "" Then
      Exit For
   End If
Next

cntColumns = cntL

ts.write("Logon Name, Context")
ts.write(", Header OU")                            ' Remove for multiple OU's
ts.writeline(", Last Logon Date, Creation Date, Home Folder, Script, Display Name, Email Address, Mail Server, Password Not Needed, Password Does Not Expire, Expired Password, Account Is Disabled")

'
''''' Finally output the data (This system is only setup for a max of 10,000 Computers
'
For cntL = 0 to 9999                                ' Cycle through all Computers found
   If aryCN(cntL,0) = "" Then                       ' Quit once end found
      Exit For
   End If

   'If this is an Replicated Exchange Object, drop it
   exFlg = InStr(1,arySvCN(cntL), "adc_replication",1)
   If exFlg = 0 Then

      ts.write(aryCN(cntL,0)) & ", "                   ' Output Computers logon name

      'Drop all comma's in the context
      tmpName = Replace(arySvCN(cntL), ",", " ")
      ts.write(tmpName) & ", "                         ' Output full context of Computer
      ts.write(aryContainer(aryCN(cntL,1)))            ' Output Computers Home OU

      Call LastTime                                    ' Sniff Out Last Time logged on

      If nLatestDate <> "1/1/1601" Then
         ts.write(", " & nLatestDate)
      Else
         ts.write(", ")
      End If
      ts.write(", ")                                    ' Date Account Was Created
      ts.write(aryWhen(cntL))
      ts.write(", ")                                    ' Home folder location
      If aryHomeDirectory(cntL) > "" Then
         ts.write(aryHomeDirectory(cntL))
      Else
         ts.write(" ")
      End If

      ts.write(", ")

      If aryScriptPath(cntL) > "" Then
         ts.write(aryScriptPath(cntL))
      Else
         ts.write(" ")
      End If

      ts.write(", ")

      If arydisplayName(cntL) > "" Then
         ts.write(arydisplayName(cntL))
      Else
         ts.write(" ")
      End If

      ts.write(", ")

      If arymail(cntL) > "" Then
         ts.write(arymail(cntL))
      Else
         ts.write(" ")
      End If

      ts.write(", ")

      If arymsExchHomeServerName(cntL) > "" Then
         ts.write(arymsExchHomeServerName(cntL))
      Else
         ts.write(" ")
      End If

         on error resume next
         Set usr = GetObject("WinNT://" & strDomainName & "/" & aryCN(cntL,0))
         flag = usr.Get("ComputerFlags")

         If flag AND ADS_UF_PASSWD_NOTREQD Then
             ts.write(", y")
         Else
             ts.write(", ")
         End If

         If flag AND ADS_UF_DONT_EXPIRE_PASSWD Then
             ts.write(", y")
         Else
             ts.write(", ")
         End If

         If flag AND ADS_UF_PASSWORD_EXPIRED Then
             ts.write(", y")
         Else
             ts.write(", ")
         End If

         If flag AND ADS_UF_ACCOUNTDISABLE Then
             ts.write(", y")
         Else
             ts.write(", ")
         End If

      ts.writeline()                                   ' Start a newline

   End If

Next

objConnection.Close
