
Imports Microsoft.MetadirectoryServices
Imports Microsoft.MetadirectoryServices.Logging

Imports System.Xml
Imports CustomUtils.Constants
Imports System.DirectoryServices
Imports System.Data.SqlClient
Imports System.Text

' <summary>Provides some utility methods to assist other modules in this application</summary>
Public Class Utilities

    Private Function Initialize() As Boolean

    End Function

    ' <summary>Cleans up illegal and inconvenient characters and replaces it with valid characters.</summary>
    ' <param name="sAMAccountName">sAMAccountName</param>
    ' <returns>String</returns>
    Public Shared Function ReplaceIllegalCharacters(ByVal sAMAccountName As String) As String

        ' Replace illegal and inconvenient characters
        sAMAccountName = sAMAccountName.Replace(" ", "")
        sAMAccountName = sAMAccountName.Replace("'", "")
        sAMAccountName = sAMAccountName.Replace("Å", "Aa")
        sAMAccountName = sAMAccountName.Replace("å", "aa")
        sAMAccountName = sAMAccountName.Replace("Ø", "Oe")
        sAMAccountName = sAMAccountName.Replace("ø", "oe")
        sAMAccountName = sAMAccountName.Replace("Æ", "Ae")
        sAMAccountName = sAMAccountName.Replace("æ", "ae")
        sAMAccountName = sAMAccountName.Replace("/", "_")
        sAMAccountName = sAMAccountName.Replace("\", "_")
        sAMAccountName = sAMAccountName.Replace(";", "_")
        sAMAccountName = sAMAccountName.Replace("]", "_")
        sAMAccountName = sAMAccountName.Replace("|", "_")
        sAMAccountName = sAMAccountName.Replace("[", "_")
        sAMAccountName = sAMAccountName.Replace("=", "_")
        sAMAccountName = sAMAccountName.Replace("+", "_")
        sAMAccountName = sAMAccountName.Replace("*", "_")
        sAMAccountName = sAMAccountName.Replace(",", "_")
        sAMAccountName = sAMAccountName.Replace(">", "_")
        sAMAccountName = sAMAccountName.Replace("?", "_")
        sAMAccountName = sAMAccountName.Replace(":", "_")
        sAMAccountName = sAMAccountName.Replace("<", "_")
        sAMAccountName = sAMAccountName.Replace(".", "_")

        ' Returns the replaced names to the function
        ReplaceIllegalCharacters = sAMAccountName

    End Function


    Public Shared Function GenerateUID(ByVal csentry As CSEntry, ByVal accountType As String, ByVal prefix As String) As String
        ' Declaration of the variables
        Dim givenName As String = Nothing
        Dim surName As String = Nothing

        givenName = ValidategivenName(csentry, accountType)
        surName = ValidateSurname(csentry, accountType)


        ' Check the presence of the first name and last name to assign them to respective variables
        'Select Case accountType
        '    Case EMPLOYEE_TYPE_FTE
        '        If csentry("PreferredName").IsPresent AndAlso csentry("Surname").IsPresent Then
        '            givenName = csentry("PreferredName").Value
        '            surName = csentry("Surname").Value
        '        Else
        '            Throw New UnexpectedDataException("Both PrefferedName and Surname are needed to generate the sAMAccountName")
        '        End If

        '    Case EMPLOYEE_TYPE_CONTRACTOR, ACCOUNT_ADMIN, ACCOUNT_RESOURCE, ACCOUNT_SERVICE
        '        If csentry("FIRST_NAME").IsPresent AndAlso csentry("LAST_NAME").IsPresent Then
        '            givenName = csentry("FIRST_NAME").Value
        '            surName = csentry("LAST_NAME").Value
        '        Else
        '            Throw New UnexpectedDataException("Both FIRST_NAME and LAST_NAME are needed to generate the sAMAccountName")
        '        End If

        'End Select

        'givenName = givenName.TrimStart(" ").TrimEnd(" ")
        'surName = surName.TrimStart(" ").TrimEnd(" ")

        '' Check to see if the surname is in one part
        'If InStr(Trim(surName), " ") Then
        '    Dim SnComponents() As String = surName.TrimStart(" ").Split(" ")
        '    surName = SnComponents.GetValue(SnComponents.Length - 1)

        'End If

        'If InStr(Trim(surName), "-") Then
        '    surName = Right(surName, (Len(surName) - InStr(surName, "-")))
        'End If

        ' The value for the sAMAccountName attribute should be unique on every metaverse entry.
        ' Use the following formular to make them unique: givenName(1..MAX_SAM_GIVENNAME) + surname(1..MAX_SAM_SURNAME) + <number>
        Dim samName As String

        ' Setting FirstPart from Connector Space Value
        Dim firstPart As String = givenName

        ' Replacing illegal characters from the givenName Value
        firstPart = ReplaceIllegalCharacters(firstPart)

        ' Testing the length of the FirstPartLength which is the Length of this attribute
        Dim firstPartLength As Integer = firstPart.Length

        If firstPartLength > MAX_SAM_GIVENNAME Then

            ' Getting the value of the First Name based on MAX_SAM_GIVENNAME
            firstPart = firstPart.Substring(0, MAX_SAM_GIVENNAME)
        End If

        ' Setting LastPart from Connector Space Value
        Dim lastPart As String = surName

        ' Replacing illegal characters from the LastPart Value
        lastPart = ReplaceIllegalCharacters(lastPart)

        ' Testing the length of the LastPart which is the Length of this attribute to ensure that it is greater than the constant for maximum length
        If lastPart.Length > MAX_SAM_SURNAME Then
            ' Getting the value of the LastName based on MAX_SAM_SURNAME
            lastPart = lastPart.Substring(0, MAX_SAM_SURNAME)
        End If

        If accountType <> Constants.ACCOUNT_RESOURCE Then '"R" Then
            samName = prefix + lastPart
        Else
            samName = lastPart + givenName
        End If

        Dim newSamName As String

        ' Calling the GetCheckedSamName Function to ensure the value is unique. Use all lower case for sAMAccountName
        newSamName = checkForExistingSAM(samName.ToLower, csentry, accountType)


        ' If an unique SAMAccoutName could not be created, throw an exception.
        If newSamName.Equals("") Then
            Throw New UnexpectedDataException("A unique sAMAccountName could not be found")
        End If

        ' Check for maximum length of SAMAccoutName
        If newSamName.Length >= MAX_SAM_LENGTH Then
            Dim msg As String = String.Format("sAMAccountName length is {0} which is larger than maximum of {1}", newSamName.Length, MAX_SAM_LENGTH)
            Throw New UnexpectedDataException(msg)
        End If

        ' Returns the New Account Name
        GenerateUID = newSamName

    End Function
    Public Shared Function generateCNfromUID(ByVal mventry As MVEntry) As String
        generateCNfromUID = Nothing

        If mventry("sn").IsPresent AndAlso mventry("givenName").IsPresent AndAlso mventry("uid").IsPresent Then
            generateCNfromUID = String.Format("{0}, {1} ({2})", mventry("sn").Value, mventry("givenName").Value, mventry("uid").Value) ' The approved format
            'generateCNfromUID = mventry("sn").Value & ", " & mventry("givenName").Value & " (" & mventry("uid").Value & ")"
        End If

    End Function

    ' <summary>Generates Account Name</summary>
    ' <param name="csEntry">Connector Space Entry</param>
    ' <param name="mvEntry">Metaverse Entry</param>
    ' <param name="isContractor">Contractor called from the respective class</param>
    ' <param name="Prefix">Prefix to be used</param>
    ' <returns>String</returns>
    Public Shared Function GeneratesAMAccountNameFP(ByVal mvEntry As MVEntry, ByVal accountType As String, ByVal Prefix As String, ByVal ADMAName As String) As String

        ' Declaration of the variables
        Dim givenName As String = Nothing
        Dim surName As String = Nothing

        ' Check the presence of the first name and last name to assign them to respective variables
        If mvEntry("firstName").IsPresent AndAlso mvEntry("lastName").IsPresent Then
            givenName = mvEntry("firstName").Value
            surName = mvEntry("lastName").Value
        ElseIf mvEntry("givenName").IsPresent AndAlso mvEntry("sn").IsPresent Then
            givenName = mvEntry("givenName").Value
            surName = mvEntry("sn").Value
        Else
            Throw New UnexpectedDataException("Both FIRST_NAME and LAST_NAME are needed to generate the sAMAccountName")
        End If

        givenName = givenName.TrimStart(" ").TrimEnd(" ")
        surName = surName.TrimStart(" ").TrimEnd(" ")

        ' Check to see if the surname is in one part
        If InStr(Trim(surName), " ") Then
            Dim SnComponents() As String = surName.TrimStart(" ").Split(" ")
            surName = SnComponents.GetValue(SnComponents.Length - 1)
        End If

        If InStr(Trim(surName), "-") Then
            surName = Right(surName, (Len(surName) - InStr(surName, "-")))
        End If

        ' The value for the sAMAccountName attribute should be unique on every metaverse entry.
        ' Use the following formular to make them unique: givenName(1..MAX_SAM_GIVENNAME) + surname(1..MAX_SAM_SURNAME) + <number>
        Dim samName As String

        ' Setting FirstPart from Connector Space Value
        Dim firstPart As String = givenName

        ' Replacing illegal characters from the givenName Value
        firstPart = ReplaceIllegalCharacters(firstPart)

        ' Testing the length of the FirstPartLength which is the Length of this attribute
        Dim firstPartLength As Integer = firstPart.Length

        If firstPartLength > MAX_SAM_GIVENNAME Then

            ' Getting the value of the First Name based on MAX_SAM_GIVENNAME
            firstPart = firstPart.Substring(0, MAX_SAM_GIVENNAME)
        End If

        ' Setting LastPart from Connector Space Value
        Dim lastPart As String = surName

        ' Replacing illegal characters from the LastPart Value
        lastPart = ReplaceIllegalCharacters(lastPart)

        ' Testing the length of the LastPart which is the Length of this attribute to ensure that it is greater than the constant for maximum length
        If lastPart.Length > MAX_SAM_SURNAME Then
            ' Getting the value of the LastName based on MAX_SAM_SURNAME
            lastPart = lastPart.Substring(0, MAX_SAM_SURNAME)
        End If

        If accountType <> Constants.ACCOUNT_RESOURCE Then '"R" Then
            samName = Prefix + lastPart
        Else
            samName = lastPart + givenName
        End If

        Dim newSamName As String
        Dim csentry As CSEntry = Nothing
        ' Calling the GetCheckedSamName Function to ensure the value is unique. Use all lower case for sAMAccountName
        newSamName = GetCheckedSamName(samName.ToLower, mvEntry, csentry, accountType, ADMAName)

        ' If an unique SAMAccoutName could not be created, throw an exception.
        If newSamName.Equals("") Then
            Throw New UnexpectedDataException("A unique sAMAccountName could not be found")
        End If

        ' Check for maximum length of SAMAccoutName
        If newSamName.Length >= MAX_SAM_LENGTH Then
            Dim msg As String = String.Format("sAMAccountName length is {0} which is larger than maximum of {1}", newSamName.Length, MAX_SAM_LENGTH)
            Throw New UnexpectedDataException(msg)
        End If

        ' Returns the New Account Name
        GeneratesAMAccountNameFP = newSamName

    End Function
    Public Shared Function generateCNfromFPDetails(ByVal mventry As MVEntry, ByVal UID As String) As String
        generateCNfromFPDetails = Nothing

        If mventry("firstName").IsPresent AndAlso mventry("lastName").IsPresent Then
            generateCNfromFPDetails = String.Format("{0}, {1} ({2})", mventry("lastName").Value, mventry("firstName").Value, UID) ' The approved format
            'generateCNfromUID = mventry("sn").Value & ", " & mventry("givenName").Value & " (" & mventry("uid").Value & ")"
        End If
    End Function
    Public Shared Function GenerateFPEmployeeID() As String
        Dim testval As String = Nothing
        Dim rand As Random = New Random()
        Dim randNum As Integer = rand.Next(100, 999)
        Dim glbZA As New System.Globalization.CultureInfo("en-ZA")
        glbZA.DateTimeFormat.MonthDayPattern = "MM"
        glbZA.DateTimeFormat.ShortDatePattern = "dd"
        glbZA.DateTimeFormat.YearMonthPattern = "yy"

        Dim employeeID As String = "FP" & Date.Now.ToString(glbZA.DateTimeFormat.YearMonthPattern) & _
                                          Date.Now.ToString(glbZA.DateTimeFormat.MonthDayPattern) & _
                                          Date.Now.ToString(glbZA.DateTimeFormat.ShortDatePattern) & _
                                          randNum.ToString


        Return employeeID

    End Function

    ' <summary>Function for checking SAM Name</summary>
    ' <param name="samName">Generated User Name</param>
    ' <param name="mvEntry">Metaverse Entry</param>
    ' <param name="csEntry">Connector Space Entry</param>
    ' <returns>String</returns>
    Public Shared Function checkForExistingSAM(ByVal samName As String, ByVal csEntry As CSEntry, ByVal accountType As String) As String
        checkForExistingSAM = Nothing
        ' Declarations
        Dim findResultList() As Microsoft.MetadirectoryServices.MVEntry
        Dim findResultListUid() As Microsoft.MetadirectoryServices.MVEntry
        Dim checkedSamName As String = samName
        Dim tmpString As String

        Dim isUniq As Boolean = False

        Dim number As Integer = 1
        Dim numberIndex As Integer = checkedSamName.Length

        ' check length of the sam account name to ensure that we adhere to 4 chars add append index value based on the length to ensure 7 char consitency
        ' before checking uniqueness

        If accountType Is "P" Or accountType = "C" Or accountType = "A" Or accountType = ACCOUNT_ADMIN Or accountType = EMPLOYEE_TYPE_CONTRACTOR Then
            'Throw New UnexpectedDataException("code stop here")
            Select Case Len(checkedSamName)
                Case 2
                    checkedSamName = checkedSamName + System.String.Format("{0:D5}", number)
                Case 3
                    checkedSamName = checkedSamName + System.String.Format("{0:D4}", number)
                Case 4
                    checkedSamName = checkedSamName + System.String.Format("{0:D3}", number)

                Case 8
                    checkedSamName = checkedSamName + System.String.Format("{0:D4}", number)
                Case 9
                    checkedSamName = checkedSamName + System.String.Format("{0:D3}", number)
                Case 10
                    checkedSamName = checkedSamName + System.String.Format("{0:D2}", number)
            End Select
        End If

        ' Create a unique naming attribute by adding a number to the existing sAMAccountName value.
        Do While Not isUniq

            ' Check if the passed sAMAccountName value exists in the metaverse by using the Utils.FindMVEntries method.
            findResultList = Utils.FindMVEntries("sAMAccountName", checkedSamName, 1)
            findResultListUid = Utils.FindMVEntries("uid", checkedSamName, 1)

            ' not in metaverse
            If findResultList.Length = 0 And _
               findResultListUid.Length = 0 Then
                checkForExistingSAM = checkedSamName
                isUniq = True

                Exit Do

            Else

                ' If the passed value already exists, rebuilt the SamName attribute with new index values to the passed value and verify this new value exists. 
                ' Repeat this step until a unique value is created.

                tmpString = checkedSamName.Remove(numberIndex, 3)
                number = number + 1

                checkedSamName = tmpString + System.String.Format("{0:D3}", number)

            End If

        Loop

    End Function


    ' <summary>Generates Account Name</summary>
    ' <param name="csEntry">Connector Space Entry</param>
    ' <param name="mvEntry">Metaverse Entry</param>
    ' <param name="isContractor">Contractor called from the respective class</param>
    ' <param name="Prefix">Prefix to be used</param>
    ' <returns>String</returns>
    Public Shared Function GeneratesAMAccountName(ByVal csEntry As CSEntry, ByVal mvEntry As MVEntry, ByVal accountType As String, ByVal Prefix As String, ByVal ADMAName As String) As String

        ' Declaration of the variables
        Dim givenName As String = Nothing
        Dim surName As String = Nothing

        givenName = ValidategivenName(csEntry, accountType)
        surName = ValidateSurname(csEntry, accountType)

        ' If csEntry("FIRST_NAME").IsPresent Then givenName = validategivenName = csEntry("FIRST_NAME").value
        ' surname = 

        ' Check the presence of the first name and last name to assign them to respective variables
        ' ValidateDisplayInfo(givenName, surName, csEntry, accountType)

        'Select Case accountType
        '    Case Constants.EMPLOYEE_TYPE_CONTRACTOR, Constants.ACCOUNT_ADMIN
        '        If csEntry("FIRST_NAME").IsPresent AndAlso csEntry("LAST_NAME").IsPresent Then
        '            givenName = csEntry("FIRST_NAME").Value
        '            surName = csEntry("LAST_NAME").Value
        '        Else
        '            Throw New UnexpectedDataException("Both FIRST_NAME and LAST_NAME are needed to generate the sAMAccountName")
        '        End If
        '    Case Constants.ACCOUNT_SERVICE
        '        If csEntry("FIRST_NAME").IsPresent Then
        '            givenName = csEntry("FIRST_NAME").Value
        '            surName = "Service"
        '        End If
        '    Case Constants.ACCOUNT_RESOURCE
        '        If csEntry("FIRST_NAME").IsPresent Then
        '            givenName = csEntry("FIRST_NAME").Value
        '            surName = "Resource"
        '        End If
        '    Case Else
        '        If csEntry("PreferredName").IsPresent AndAlso csEntry("Surname").IsPresent Then
        '            givenName = csEntry("PreferredName").Value
        '            surName = csEntry("Surname").Value
        '        Else
        '            Throw New UnexpectedDataException("Both PrefferedName and Surname are needed to generate the sAMAccountName")
        '        End If
        'End Select

        'givenName = givenName.TrimStart(" ").TrimEnd(" ")
        'surName = surName.TrimStart(" ").TrimEnd(" ")

        '' Check to see if the surname is in one part
        'If InStr(Trim(surName), " ") Then
        '    Dim SnComponents() As String = surName.TrimStart(" ").Split(" ")
        '    surName = SnComponents.GetValue(SnComponents.Length - 1)

        '    '            surName = Right(surName, (Len(surName) - InStr(surName, " ")))
        'End If

        'If InStr(Trim(surName), "-") Then
        '    surName = Right(surName, (Len(surName) - InStr(surName, "-")))
        'End If

        ' The value for the sAMAccountName attribute should be unique on every metaverse entry.
        ' Use the following formular to make them unique: givenName(1..MAX_SAM_GIVENNAME) + surname(1..MAX_SAM_SURNAME) + <number>
        Dim samName As String

        ' Setting FirstPart from Connector Space Value
        Dim firstPart As String = givenName

        ' Replacing illegal characters from the givenName Value
        firstPart = ReplaceIllegalCharacters(firstPart)

        ' Testing the length of the FirstPartLength which is the Length of this attribute
        Dim firstPartLength As Integer = firstPart.Length

        If firstPartLength > MAX_SAM_GIVENNAME Then

            ' Getting the value of the First Name based on MAX_SAM_GIVENNAME
            firstPart = firstPart.Substring(0, MAX_SAM_GIVENNAME)
        End If

        ' Setting LastPart from Connector Space Value
        Dim lastPart As String = surName

        ' Replacing illegal characters from the LastPart Value
        lastPart = ReplaceIllegalCharacters(lastPart)

        ' Testing the length of the LastPart which is the Length of this attribute to ensure that it is greater than the constant for maximum length
        If lastPart.Length > MAX_SAM_SURNAME Then
            ' Getting the value of the LastName based on MAX_SAM_SURNAME
            lastPart = lastPart.Substring(0, MAX_SAM_SURNAME)
        End If

        If accountType <> Constants.ACCOUNT_RESOURCE Then '"R" Then
            samName = Prefix + lastPart
        Else
            samName = lastPart + givenName
        End If

        Dim newSamName As String

        ' Calling the GetCheckedSamName Function to ensure the value is unique. Use all lower case for sAMAccountName
        newSamName = GetCheckedSamName(samName.ToLower, mvEntry, csEntry, accountType, ADMAName)


        ' If an unique SAMAccoutName could not be created, throw an exception.
        If newSamName.Equals("") Then
            Throw New UnexpectedDataException("A unique sAMAccountName could not be found")
        End If

        ' Check for maximum length of SAMAccoutName
        If newSamName.Length >= MAX_SAM_LENGTH Then
            Dim msg As String = String.Format("sAMAccountName length is {0} which is larger than maximum of {1}", newSamName.Length, MAX_SAM_LENGTH)
            Throw New UnexpectedDataException(msg)
        End If

        ' Returns the New Account Name
        GeneratesAMAccountName = newSamName

    End Function

    ' <summary>Function for checking SAM Name</summary>
    ' <param name="samName">Generated User Name</param>
    ' <param name="mvEntry">Metaverse Entry</param>
    ' <param name="csEntry">Connector Space Entry</param>
    ' <returns>String</returns>
    Public Shared Function GetCheckedSamName(ByVal samName As String, ByVal mvEntry As MVEntry, ByVal csEntry As CSEntry, ByVal accountType As String, ByVal ADMAName As String) As String
        GetCheckedSamName = Nothing
        ' Declarations
        Dim findResultList() As Microsoft.MetadirectoryServices.MVEntry
        Dim checkedSamName As String = samName
        Dim tmpString As String
        Dim newNumber As String = Nothing
        Dim isUniq As Boolean = False

        Dim number As Integer = 1
        Dim numberIndex As Integer = checkedSamName.Length

        Dim mvEntryFound As MVEntry

        ' check length of the sam account name to ensure that we adhere to 4 chars add append index value based on the length to ensure 7 char consitency
        ' before checking uniqueness

        If accountType Is "P" Or accountType = "C" Or accountType = "A" Or accountType = ACCOUNT_ADMIN Or accountType = EMPLOYEE_TYPE_CONTRACTOR Then
            Select Case Len(checkedSamName)
                Case 2
                    checkedSamName = checkedSamName + System.String.Format("{0:D5}", number)
                Case 3
                    checkedSamName = checkedSamName + System.String.Format("{0:D4}", number)
                Case 4
                    checkedSamName = checkedSamName + System.String.Format("{0:D3}", number)
                Case 8
                    checkedSamName = checkedSamName + System.String.Format("{0:D4}", number)
                Case 9
                    checkedSamName = checkedSamName + System.String.Format("{0:D3}", number)
                Case 10
                    checkedSamName = checkedSamName + System.String.Format("{0:D2}", number)
            End Select
        End If

        ' Create a unique naming attribute by adding a number to the existing sAMAccountName value.
        Do While Not isUniq

            ' Check if the passed sAMAccountName value exists in the metaverse by using the Utils.FindMVEntries method.
            findResultList = Utils.FindMVEntries("sAMAccountName", checkedSamName, 1)

            ' not in metaverse
            If findResultList.Length = 0 Then
                ' might still be unconnected in AD
                '  If mvEntry.ConnectedMAs(ADMAName).Connectors.Count = 0 Then
                'If Not _adHelper.AccountExists(checkedSamName) Then
                GetCheckedSamName = checkedSamName
                isUniq = True
                Exit Do
                'End If
            Else
                ' Check that the connector space entry is connected to the metaverse entry.
                mvEntryFound = findResultList(0)
                If mvEntryFound Is mvEntry Then
                    GetCheckedSamName = checkedSamName
                    Exit Do
                End If
            End If

            ' If the passed value already exists, rebuilt the SamName attribute with new index values to the passed value and verify this new value exists. 
            ' Repeat this step until a unique value is created.

            tmpString = checkedSamName.Remove(numberIndex, 3)
            number = number + 1

            newNumber = System.String.Format("{0:D3}", number)
            checkedSamName = tmpString & System.String.Format("{0:D3}", number)

        Loop

    End Function

    ''' <summary>
    ''' This function determines if the custom default password must be used, if not then generates a random password
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function Get_InitialPassword(ByVal useCustomPassword As Boolean, ByVal customPassword As String) As String
        Get_InitialPassword = Nothing

        If useCustomPassword Then ' Set the initial password to the custompassword if the condition is set to True
            Get_InitialPassword = customPassword
        Else
            ' Generate a random password for usage in Active Directory
            Get_InitialPassword = New Password_Generator().Generate()
        End If

    End Function

    Public Shared Function ValidategivenName(ByVal csentry As csentry, ByVal accountType As String)

        ValidategivenName = Nothing

        Select Case accountType
            Case Constants.EMPLOYEE_TYPE_CONTRACTOR, _
                 Constants.ACCOUNT_ADMIN, _
                 Constants.ACCOUNT_SERVICE, _
                 Constants.ACCOUNT_RESOURCE
                ValidategivenName = csEntry("FIRST_NAME").Value
            Case Else
                If csentry("PreferredName").ispresent Then
                    ValidategivenName = csentry("PreferredName").Value
                Else
                    ValidategivenName = csentry("FirstName").Value
                End If
        End Select

        ValidategivenName = ValidategivenName.TrimStart(" ").TrimEnd(" ")
       
    End Function

    Public Shared Function ValidateSurname(ByVal csentry As CSEntry, _
                                               ByVal accountType As String)
        ValidateSurname = Nothing
        Dim surname As String = Nothing

        Select Case accountType
            Case Constants.EMPLOYEE_TYPE_CONTRACTOR, Constants.ACCOUNT_ADMIN
                If csentry("LAST_NAME").IsPresent Then
                    ValidateSurname = csentry("LAST_NAME").Value
                Else
                    Throw New UnexpectedDataException("LAST_NAME are needed to generate the sAMAccountName")
                End If
            Case Constants.ACCOUNT_SERVICE
                ValidateSurname = "Service"
            Case Constants.ACCOUNT_RESOURCE
                ValidateSurname = "Resource"
            Case Else
                If csentry("Surname").IsPresent Then
                    ValidateSurname = csentry("Surname").Value
                End If
        End Select


        ValidateSurname = ValidateSurname.TrimStart(" ").TrimEnd(" ")

        ' Check to see if the ValidateSurname is in one part
        If InStr(Trim(ValidateSurname), " ") Then
            Dim SnComponents() As String = ValidateSurname.TrimStart(" ").Split(" ")
            ValidateSurname = SnComponents.GetValue(SnComponents.Length - 1)

        End If

        If InStr(Trim(ValidateSurname), "-") Then
            ValidateSurname = Right(ValidateSurname, (Len(ValidateSurname) - InStr(ValidateSurname, "-")))
        End If

    End Function

    Public Shared Function CheckAccountState(ByVal UserAccountControl As Integer, ByVal AccountEnabledState As Boolean) As Integer
        'Get current state of value
        Select Case UserAccountControl
            Case UF_NORMAL_ACCOUNT, _
                 UF_NORMAL_ACCOUNT + UF_PASSWD_NOTREQD, _
                 UF_NORMAL_ACCOUNT + UF_DONT_EXPIRE_PASSWD ' Active Accounts
                Select Case AccountEnabledState
                    Case True
                        Return UserAccountControl
                    Case False
                        Return UserAccountControl + UF_ACCOUNTDISABLE
                End Select

            Case UF_NORMAL_ACCOUNT + UF_ACCOUNTDISABLE, _
                 UF_NORMAL_ACCOUNT + UF_ACCOUNTDISABLE + UF_PASSWD_NOTREQD, _
                 UF_NORMAL_ACCOUNT + UF_DONT_EXPIRE_PASSWD + UF_ACCOUNTDISABLE ' Disabled Accounts
                Select Case AccountEnabledState
                    Case True
                        Return UserAccountControl - UF_ACCOUNTDISABLE
                    Case False
                        Return UserAccountControl
                End Select

        End Select


    End Function


#Region "SSP Mastersite Functions"

    Public Shared Function GetSiteInfo(ByVal SiteCode As String, ByVal FieldType As String) As String
        GetSiteInfo = String.Empty
        Dim mventrySites() As MVEntry = Utils.FindMVEntries("eakb-ID", SiteCode, 1)
        If mventrySites.Length > 0 Then
            Try
                If mventrySites(0).Item(FieldType).IsPresent Then
                    If Not mventrySites(0).Item(FieldType).Value = String.Empty Then
                        GetSiteInfo = mventrySites(0).Item(FieldType).Value
                    End If
                End If
            Catch ex As Exception
                Return Nothing
            End Try
        End If
        Return GetSiteInfo
    End Function

#End Region

#Region "Change Tracker"
    Public Shared Sub checkchangeTrackerValue(ByVal mventry As MVEntry, ByVal csentry As CSEntry, ByVal fieldtoCheck As String, ByVal CSField As String, ByVal MVField As String)

        'check to see if the checking field exists
        If mventry("ChangeTracker").Values.Contains(fieldtoCheck) = False Then
            mventry("ChangeTracker").Values.Add(fieldtoCheck + ":" + csentry(CSField).Value + "," + mventry(MVField).Value + "," + "No Change")
            Exit Sub
        Else
            Dim mvVal As String = Nothing
            Dim csVal As String = Nothing
            Dim Changetracker() As String = Nothing
            Dim valCol As Microsoft.MetadirectoryServices.ValueCollection = Nothing

            Dim Splitlen As Integer = fieldtoCheck.Length + 1
            For i As Integer = 0 To mventry("ChangeTracker").Values.Count - 1
                If mventry("ChangeTracker").Values.Item(i).ToString.Contains(fieldtoCheck) Then
                    Changetracker = mventry("ChangeTracker").Values.Item(i).ToString.Substring(Splitlen).Split(",")
                    csVal = Changetracker.GetValue(0)
                    mvVal = Changetracker.GetValue(1)
                    If Not String.Compare(csVal, mvVal, True) = 0 Then
                        valCol.Add(fieldtoCheck + ":" + csentry(CSField).Value + "," + mventry(MVField).Value + "," + "Changed")

                    Else : valCol.Add(fieldtoCheck + ":" + csentry(CSField).Value + "," + mventry(MVField).Value + "," + "No Change")
                    End If
                Else
                    valCol.Add(mventry("ChangeTracker").Values.Item(i).ToString)

                End If
            Next

            mventry("ChangeTracker").Values = valCol

        End If
    End Sub

#End Region

#Region "Logging Functions"
    ''' <summary>
    ''' This subroutine function writes to the event log if the case of errors being generated by the rules extension library
    ''' </summary>
    ''' <param name="Message"></param>
    ''' <param name="LogType"></param>
    ''' <param name="throwError"></param>
    ''' <remarks></remarks>
    Public Shared Sub WriteToLog(ByVal Message As String, ByVal LogType As Integer, ByVal throwError As Boolean)

        Log(Message, True, LogType)

        Select Case LogType 'if the eventlog type is clasified as an error or critical error , throw an exception with the message.
            Case LOG_CRIT, LOG_ERROR
                If throwError = True Then
                    Throw New UnexpectedDataException(Message)
                End If
        End Select
    End Sub
#End Region

End Class

