
Imports Microsoft.MetadirectoryServices
Imports System.Configuration.ConfigurationManager

Imports CustomUtils
Imports CustomUtils.Utilities
Imports CustomUtils.Constants

Public Class MVExtensionObject
    Implements IMVSynchronization

    Dim employeesContainer As String = AppSettings("employeesOU")
    Dim adminaccountsContainer As String = AppSettings("adminaccountsOU")
    Dim serviceaccountsContainer As String = AppSettings("serviceaccountsOU")
    Dim resourceaccountsContainer As String = AppSettings("resourceaccountsOU")
    Dim disabledContainer As String = AppSettings("disabledusersOU")
    Dim contactsContainer As String = AppSettings("contactsOU")
    Dim groupsContainer As String = AppSettings("groupsOU")
    Dim ExchSMTPServer As String = AppSettings("ExchSMTPServer")
    Dim homeMDB As String = AppSettings("homeMDBPath")
    Dim msExchHomeServerName As String = AppSettings("homeServer")
    Dim SMTPSuffix As String = AppSettings("SMTPSuffix")
    Dim ADMAName As String = AppSettings("ADMA")
    Dim HRMAName As String = AppSettings("HRMA")
    Dim ROAMAName As String = AppSettings("ROAMA")
    Dim SSProvMAName As String = AppSettings("SSPMA")
    'Dim FIMPortalMAName As String = AppSettings("FPMA")
    Dim defaultManagerEmail As String = AppSettings("defaultManagerEmail")
    Dim customPassword As String = AppSettings("CustomPassword")
    Dim useCustomPassword As Boolean = CType(AppSettings("UseCustomPassword").ToString, Boolean)
    Dim Prefix_FteAcc As String = AppSettings("permanentPrefix").ToString
    Dim Prefix_CntAcc As String = AppSettings("contractorPrefix").ToString
    Dim Prefix_SvcAcc As String = AppSettings("serviceAccountPrefix").ToString
    Dim Prefix_ResAcc As String = AppSettings("AccountPrefix").ToString
    Dim Prefix_AdmAcc As String = AppSettings("adminPrefix").ToString
    Dim Prefix_ShdAcc As String = AppSettings("sharedAccountPrefix").ToString
    Dim ProvisionfromHR As Boolean = Boolean.Parse(AppSettings("ProvisionfromHR").ToString)
    Dim ProvisionfromROA As Boolean = Boolean.Parse(AppSettings("ProvisionfromROA").ToString)
    Dim provisionfromSSP As Boolean = Boolean.Parse(AppSettings("ProvisionfromSSP").ToString)
    Dim provisionfromFP As Boolean = Boolean.Parse(AppSettings("ProvisionfromFP").ToString)
    Dim logonMonths As Integer = Integer.Parse(AppSettings("logonMonths").ToString)

    Public Sub Initialize() Implements IMvSynchronization.Initialize
        ' TODO: Add initialization code here
    End Sub

    Public Sub Terminate() Implements IMvSynchronization.Terminate
        ' TODO: Add termination code here
    End Sub

    Public Sub Provision(ByVal mventry As MVEntry) Implements IMVSynchronization.Provision
        ' For each Mventry ObjectType, corresponding operations should be performed
        Select Case mventry.ObjectType.ToLower()

            ' If the object type is group , then create an AD group, not currently implemented as the group populator is not in use
            Case "group"
                'CreateADGroup(mventry)

                ' If the object type is person , then create an AD user
            Case "person", "ssoperson"

                CreateADUser(mventry)

            Case "mastersite", "usedadaccountnames", "department", "company" ' Do Nothing for these object types, will only project into the MV
            Case Else
                ' Generate an error if another type of object tries to provision
                Throw New EntryPointNotImplementedException()
        End Select
    End Sub

    Public Function ShouldDeleteFromMV(ByVal csentry As CSEntry, ByVal mventry As MVEntry) As Boolean Implements IMVSynchronization.ShouldDeleteFromMV
        ' TODO: Add MV deletion code here
        Throw New EntryPointNotImplementedException()
    End Function


    ''' <summary>
    ''' This subroutine function creates Active Directory user objects in the connector space for objects that don't already exist with the required initial values for the object to be created successfully
    ''' </summary>
    ''' <param name="mvEntry"></param>
    ''' <remarks>
    ''' Required initial values:
    ''' 1. DN
    ''' 2. CN
    ''' 3. userPrincipalName
    ''' 4. sAMAccountName
    ''' 5. unicodePwd (sets initial Password)
    ''' 6. userAccountControl (enabled by default)
    ''' 7. pwdLastSet (set to 0 to enforce password change on first logon)
    ''' 
    ''' If the user type requires a Mailbox, the following initial values are also set:
    ''' 1. homeMDB
    ''' 2. mailNickName
    ''' 3. msExchHomeServerName
    ''' 
    '''  Process to reverse-join existing AD object to VIP:
    ''' 1. VIP Full Import 
    ''' 2. AD Full Import 
    ''' 3. AD Full Sync
    '''
    ''' If MV object already exists (eg connected to wrong AD object):
    ''' 1. disconnect duplicate AD account, delete the incorrect AD Account
    ''' 2. verify employeecode in extensionAttr6
    ''' 3. Repeat the above reverse join process
    ''' 
    ''' !!!!!!!! Note that a new object will have to be exported to AD from the connector space before it will exist in AD
    ''' </remarks>
    Private Sub CreateADUser(ByVal mvEntry As MVEntry)

        Dim ADMA As ConnectedMA = mvEntry.ConnectedMAs(ADMAName) 'Use the AD MA pointed to by ADMAName
        Dim SSProvMA As ConnectedMA = mvEntry.ConnectedMAs(SSProvMAName)
        Dim HRMA As ConnectedMA '= mvEntry.ConnectedMAs(HRMAName)
        Dim ROAMA As ConnectedMA = mvEntry.ConnectedMAs(ROAMAName)

        Dim InitialPassword As String = Get_InitialPassword() ' Stored as it is used both during provisioning and sending of email
        Dim SourceMA As String = Nothing
        Dim uid As String = Nothing
        Dim cn As String = Nothing

        If ProvisionfromHR Then ' Provisioning from HR into AD
            HRMA = mvEntry.ConnectedMAs(HRMAName)
            If HRMA.Connectors.Count = 1 AndAlso ADMA.Connectors.Count = 0 Then
                ProvisionADUserFromHR(mvEntry, ADMA)
            End If
        ElseIf ProvisionfromROA Then ' Provisioning from ROA into AD
            If ROAMA.Connectors.Count = 1 AndAlso ADMA.Connectors.Count = 0 Then
                ProvisionADUserFromHR(mvEntry, ADMA)
            End If
        ElseIf SSProvMA.Connectors.Count = 1 AndAlso ADMA.Connectors.Count = 0 Then ' Provisioning from FIMPortal into AD
            If provisionfromSSP Then
                ProvisionADUserFromFIMPortal(mvEntry, ADMA)
            End If
        ElseIf ADMA.Connectors.Count = 1 Then
            ProcessExistingADUser(mvEntry, ADMA)
        ElseIf ADMA.Connectors.Count >= 1 Then
            For i As Integer = ADMA.Connectors.Count - 1 To 0 Step -1
                If Not ADMA.Connectors.ByIndex(i).ConnectionRule = RuleType.Join Then
                    ADMA.Connectors.ByIndex(i).Deprovision()
                End If
            Next
            If ADMA.Connectors.Count > 1 Then
                Try
                    WriteToLog(String.Format("Multiple connectors: {0} exists for the same account {1}", ADMA.Connectors.Count, mvEntry("employeeID").Value), LOG_ERROR, True)
                Catch ex As Exception

                End Try
            End If
        End If
    End Sub

    Private Sub ProvisionADUserFromHR(ByVal MVEntry As MVEntry, ByVal ADMA As ConnectedMA)

        Dim employeeStatus As String = Nothing
        Dim employeeType As String = Nothing
        Dim container As String = Nothing
        Dim rdn As String = Nothing ' Used to store the user relative DN
        Dim DNValue As ReferenceValue = Nothing ' Used to construct a DN value from the rdn, container 
        Dim CSEntry As CSEntry = Nothing
        Dim uid As String = Nothing
        Dim cn As String = Nothing

        If Not MVEntry("employeeStatus").IsPresent AndAlso MVEntry("employeeId").IsPresent Then
            WriteToLog("Error: employeeStatus expected for employee= " + MVEntry("employeeId").Value, LOG_INFO, True)
            ' Exit Sub  ' Exit the subroutine to as the minimum criteria was not met for provisioning a user
        ElseIf Not MVEntry("employeeStatus").IsPresent Then
            WriteToLog("Error: employeeStatus expected for employee= " + MVEntry.ObjectID.ToString, LOG_INFO, True)
            '      Exit Sub  ' Exit the subroutine to as the minimum criteria was not met for provisioning a user
        End If

        ' Based on the value of "cn" determine the RDN in AD Test for existence of employeeStatus
        If Not MVEntry("uid").IsPresent AndAlso MVEntry("employeeId").IsPresent Then
            WriteToLog("uid expected for employee= " + MVEntry("employeeId").Value, LOG_ERROR, True)
            Exit Sub  ' Exit the subroutine as the minimum criteria was not met for provisioning a user
        ElseIf Not MVEntry("uid").IsPresent Then
            WriteToLog("uid expected for employee= " + MVEntry.ObjectID.ToString, LOG_ERROR, True)
            Exit Sub  ' Exit the subroutine as the minimum criteria was not met for provisioning a user
        End If

        If MVEntry("employeeStatus").IsPresent Then employeeStatus = MVEntry("employeeStatus").Value ' Gets and stores the employee status of the user object record
        If MVEntry("employeeType").IsPresent Then employeeType = MVEntry("employeeType").Value ' Gets and stores the employee type  of the user object record

        If Not employeeStatus = Nothing AndAlso Not employeeType = Nothing Then container = Get_ADOU(employeeType, employeeStatus) ' Gets and stores the container OU where the object should be created based on the employee status and type

        ' Test for existence of container, if the required attributes are not available, write the error to the event log.
        If container = Nothing Then
            'WriteToLog("Critical: Illegal employeeStatus= " + employeeStatus.ToString + " for employeeId " + mvEntry("employeeId").Value.ToString, LOG_CRIT, True)
            Exit Sub  ' Exit the subroutine as the minimum criteria was not met for provisioning a user
        End If

        If Not MVEntry("uid").Value.ToString.Length > 4 Then
            Throw New UnexpectedDataException("The UID does not meet the minimum requirement, please check the first,preffered and lastname values from the source Management agent: " & HRMAName)
        End If

        'Only provision a user when they are network access enabled
        If Not MVEntry("NetworkAccess").BooleanValue = True Then
            Exit Sub
        End If

        uid = MVEntry("uid").Value.ToString
        cn = Utilities.generateCNfromUID(MVEntry)

        ' If there is no connector present, add a new AD connector

        ' Now construct the DN based on RDN and Container, which is used for the Active Directory CS object's distinguished name
        rdn = "CN=" & cn
        DNValue = ADMA.EscapeDNComponent(rdn).Concat(container)

        'Create a new user connector on the AD MA
        CSEntry = ADMA.Connectors.StartNewConnector("user")

        ' Set initial Values
        CSEntry("unicodePwd").Values.Add(Get_InitialPassword) ' Set the intial password
        CSEntry("cn").Value = cn 'mvEntry("cn").Value ' Set the CN value
        CSEntry("sAMAccountName").Value = uid ' Set the sAMAccountName value
        CSEntry("userPrincipalName").Value = uid & AppSettings("DomainSuffix").ToString ' Set the userPrincipalName value
        CSEntry("pwdLastSet").IntegerValue = 0 ' Set the pwdLastSet value
        CSEntry("userAccountControl").IntegerValue = Get_userAccountControl(employeeType) ' Set the userAccountControl value

        Dim randomnumber As New Random()
        Dim MDBDatabase As String = "CN=MDB00" & randomnumber.Next(1, 6).ToString
        CSEntry("homeMDB").Value = MDBDatabase & "," & homeMDB  ' Set the homeMDB value
        CSEntry("mailNickName").Value = uid ' Set the mailNickName value
        CSEntry("msExchHomeServerName").Value = msExchHomeServerName ' Set the msExchHomeServerName value

        CSEntry.DN = DNValue 'Set the DN value for the object

        Try
            CSEntry.CommitNewConnector() ' Commit the connector to the connector space
        Catch ex As ObjectAlreadyExistsException
            Exit Sub

        Catch ex As Exception ' Catch all exceptions and generate an exception.
            WriteToLog("Critical: Cannot provision user to the AD Connector space for employeeId " + MVEntry("employeeId").Value.ToString + " with the error: " + ex.ToString, LOG_ERROR, True)
            Exit Sub  ' Exit the subroutine as the minimum criteria was not met for provisioning a user
        End Try

    End Sub


    ''' <summary>
    ''' This function provisions a user created in the Portal to Active Directory
    ''' </summary>
    ''' <param name="MVEntry"></param>
    ''' <param name="ADMA"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Sub ProvisionADUserFromFIMPortal(ByVal MVEntry As MVEntry, ByVal ADMA As ConnectedMA)
        Dim employeeStatus As String = Nothing
        Dim employeeType As String = Nothing
        Dim prefix As String = Nothing
        Dim employeeID As String = Nothing
        Dim FromFIMPortal As Boolean = False
        Dim container As String = Nothing
        Dim rdn As String = Nothing ' Used to store the user relative DN
        Dim DNValue As ReferenceValue = Nothing ' Used to construct a DN value from the rdn, container 
        Dim CSEntry As CSEntry = Nothing
        Dim cn As String = Nothing
        Dim uid As String = Nothing
        Dim AccountStartDate As DateTime
        'Dim AccountEndDate As DateTime
        Dim CompareDate As DateTime
        Dim ProvisionMailbox As Boolean = False

        'This Section evaluates the constraints for not provisioning an account 
        '------------------------------------------------------------------------
        'If MVEntry("notForProvisionToAD").IsPresent AndAlso MVEntry("notForProvisionToAD").BooleanValue = True Then
        '    Exit Sub
        'End If
        CompareDate = Date.Now.AddMonths(3)
        'Try

        '    AccountStartDate = Date.Parse(MVEntry("EmployeeStartDate").Value.ToString)
        '    Dim intComparedDate As Integer = Date.Compare(AccountStartDate, CompareDate)

        '    If Date.Compare(AccountStartDate, CompareDate) > 0 Then
        '        Throw New System.IO.InvalidDataException("The Start Date for the Account is too far into the future, Please ensure that the date falls within a 3 month period from the current date")
        '    End If

        'Catch ex As Exception
        'End Try
        If Not MVEntry("EmployeeType").IsPresent Then
            Exit Sub
        End If

        '------------------------------------------------------------------------
        employeeType = MVEntry("EmployeeType").Value
        employeeStatus = EMPLOYEE_ACTIVE

        Select Case MVEntry("EmployeeType").Value
            Case "Full Time Employee"
                employeeType = EMPLOYEE_TYPE_FTE
                prefix = Prefix_FteAcc
                'If MVEntry("mailEnabled").IsPresent AndAlso MVEntry("mailEnabled").BooleanValue = True Then
                ProvisionMailbox = False
                'End If
            Case "Contractor"
                employeeType = EMPLOYEE_TYPE_CONTRACTOR
                prefix = Prefix_CntAcc
                'If MVEntry("mailEnabled").IsPresent AndAlso MVEntry("mailEnabled").BooleanValue = True Then
                ProvisionMailbox = False
                'End If
            Case "Resource Account"
                employeeType = ACCOUNT_RESOURCE
                prefix = Prefix_ResAcc
                If MVEntry("mailEnabled").IsPresent AndAlso MVEntry("mailEnabled").BooleanValue = True Then
                    ProvisionMailbox = True
                End If
            Case "Admin Account"
                employeeType = ACCOUNT_ADMIN
                prefix = Prefix_AdmAcc
                If MVEntry("mailEnabled").IsPresent AndAlso MVEntry("mailEnabled").BooleanValue = True Then
                    ProvisionMailbox = True
                End If
            Case "Service Account"
                employeeType = ACCOUNT_SERVICE
                prefix = Prefix_SvcAcc
                If MVEntry("mailEnabled").IsPresent AndAlso MVEntry("mailEnabled").BooleanValue = True Then
                    ProvisionMailbox = True
                End If
            Case "Shared Account"
                employeeType = ACCOUNT_SHARED
                prefix = Prefix_ShdAcc
                If MVEntry("mailEnabled").IsPresent AndAlso MVEntry("mailEnabled").BooleanValue = True Then
                    ProvisionMailbox = True
                End If
            Case Else
                Exit Sub
        End Select

        If Not employeeStatus = Nothing AndAlso Not employeeType = Nothing Then container = Get_ADOU(employeeType, employeeStatus)

        uid = GeneratesAMAccountNameFP(MVEntry, employeeType, prefix, ADMAName)

        cn = Utilities.generateCNfromFPDetails(MVEntry, uid)

        ' If there is no connector present, add a new AD connector
        ' Now construct the DN based on RDN and Container, which is used for the Active Directory CS object's distinguished name
        rdn = "CN=" & cn
        DNValue = ADMA.EscapeDNComponent(rdn).Concat(container)

        'Create a new user connector on the AD MA
        CSEntry = ADMA.Connectors.StartNewConnector("user")
        Dim domainSuffix As String = AppSettings("DomainSuffix").ToString
        ' Set initial Values
        CSEntry("unicodePwd").Values.Add(Get_InitialPassword) ' Set the intial password
        CSEntry("cn").Value = cn 'mvEntry("cn").Value ' Set the CN value
        CSEntry("sAMAccountName").Value = uid ' Set the sAMAccountName value
        CSEntry("userPrincipalName").Value = uid & AppSettings("DomainSuffix").ToString ' Set the userPrincipalName value
        CSEntry("pwdLastSet").IntegerValue = 0 ' Set the pwdLastSet value
        CSEntry("userAccountControl").IntegerValue = Get_userAccountControl(employeeType) ' Set the userAccountControl value
        CSEntry("employeeID").Value = MVEntry("employeeID").Value
        'CSEntry("extensionAttribute6").Value = MVEntry("employeeID").Value

        If ProvisionMailbox = True Then
            Dim randomnumber As New Random()
            Dim MDBDatabase As String = "CN=MDB00" & randomnumber.Next(1, 6).ToString
            CSEntry("homeMDB").Value = MDBDatabase & "," & homeMDB  ' Set the homeMDB value
            CSEntry("mailNickName").Value = uid ' Set the mailNickName value
            CSEntry("msExchHomeServerName").Value = msExchHomeServerName ' Set the msExchHomeServerName value
        End If

        CSEntry.DN = DNValue 'Set the DN value for the object

        Try
            CSEntry.CommitNewConnector() ' Commit the connector to the connector space
        Catch ex As ObjectAlreadyExistsException
            Exit Sub
        Catch ex As Exception ' Catch all exceptions and generate an exception.
            WriteToLog("Critical: Cannot provision user to the AD Connector space for user " + MVEntry("displayName").Value.ToString + " with the error: " + ex.ToString, LOG_ERROR, True)
            Exit Sub  ' Exit the subroutine as the minimum criteria was not met for provisioning a user
        End Try

    End Sub


    Private Sub ProcessExistingADUser(ByVal MVEntry As MVEntry, ByVal ADMA As ConnectedMA)

        Dim employeeStatus As String = Nothing
        Dim employeeType As String = Nothing
        Dim container As String = Nothing
        Dim rdn As String = Nothing ' Used to store the user relative DN
        Dim DNValue As ReferenceValue = Nothing ' Used to construct a DN value from the rdn, container 
        Dim CSEntry As CSEntry = Nothing
        If MVEntry("employeeStatus").IsPresent Then employeeStatus = MVEntry("employeeStatus").Value ' Gets and stores the employee status of the user object record
        If MVEntry("employeeType").IsPresent Then employeeType = MVEntry("employeeType").Value ' Gets and stores the employee type  of the user object record

        If Not employeeStatus = Nothing AndAlso Not employeeType = Nothing Then container = Get_ADOU(employeeType, employeeStatus) ' Gets and stores the container OU where the object should be created based on the employee status and type

        ' Test for existence of container, if the required attributes are not available, write the error to the event log.
        If container = Nothing Then
            'WriteToLog("Critical: Illegal employeeStatus= " + employeeStatus.ToString + " for employeeId " + mvEntry("employeeId").Value.ToString, LOG_CRIT, True)
            Exit Sub  ' Exit the subroutine as the minimum criteria was not met for provisioning a user
        End If
        ' lastLogonDateStamp()



        CSEntry = ADMA.Connectors.ByIndex(0) ' Get the existing connector 
        rdn = "CN=" & CSEntry("cn").Value
        DNValue = ADMA.EscapeDNComponent(rdn).Concat(container)

        Select Case MVEntry("employeeType").Value ' If the employeetype matches, check that the DN is correct for the user.
            Case ACCOUNT_ADMIN, ACCOUNT_SERVICE, ACCOUNT_RESOURCE
                If Not CSEntry.DN.ToString.ToLower = DNValue.ToString.ToLower Then ' FIM will rename/move if different, if not nothing will happen
                    CSEntry.DN = DNValue
                End If
            Case EMPLOYEE_TYPE_FTE, EMPLOYEE_TYPE_CONTRACTOR, EMPLOYEE_TYPE_CONTRACTOR_FP, ACCOUNT_SHARED
                If Not CSEntry.DN.ToString.ToLower = DNValue.ToString.ToLower Then ' FIM will rename/move if different, if not nothing will happen
                    CSEntry.DN = DNValue
                End If


        End Select

    End Sub

    ''' <summary>
    ''' This function returns the OU where the user should be created in
    ''' </summary>
    ''' <param name="UserType"></param>
    ''' <param name="UserStatus"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function Get_ADOU(ByVal UserType As String, ByVal UserStatus As String) As String
        Get_ADOU = Nothing 'initial value to ensure that an error is generated if no container can be assigned

        Select Case UserStatus 'get the user status 
            Case EMPLOYEE_RETIRED, EMPLOYEE_DISABLED ' if the employee status matches these statuses, move them into disabledContainer
                Return disabledContainer

            Case EMPLOYEE_ACTIVE, EMPLOYEE_ACTIVE_FP ' If the employee is active, proces the subroutine and move them into the appropriate OU
                Select Case UserType
                    Case EMPLOYEE_TYPE_FTE, EMPLOYEE_TYPE_CONTRACTOR, EMPLOYEE_TYPE_CONTRACTOR_FP, ACCOUNT_SHARED
                        Return employeesContainer
                    Case ACCOUNT_ADMIN
                        Return adminaccountsContainer
                    Case ACCOUNT_SERVICE
                        Return serviceaccountsContainer
                    Case ACCOUNT_RESOURCE
                        Return resourceaccountsContainer
                End Select
        End Select
    End Function

    ''' <summary>
    ''' This function returns a boolean value to indicate if the user needs an exchange mailbox 
    ''' </summary>
    ''' <param name="employeeType"></param>
    ''' <returns></returns>
    ''' <remarks>
    ''' In case of Accounts for services, administration or resources no mailboxes will be required and these type values are as follows:
    ''' 1. ACCOUNT_ADMIN
    ''' 2. ACCOUNT_SERVICE
    ''' 3. ACCOUNT_RESOURCE
    ''' </remarks>
    Private Function Get_NeedsMailbox(ByVal employeeType As String) As Boolean

        Get_NeedsMailbox = False 'The default value is set as false and will only be changed for types that need mailboxes.

        Select Case employeeType

            ' In case of Employees
            Case EMPLOYEE_TYPE_FTE, EMPLOYEE_TYPE_CONTRACTOR, EMPLOYEE_TYPE_CONTRACTOR_FP
                Get_NeedsMailbox = True
        End Select

    End Function

    ''' <summary>
    ''' This function determines and returns the correct userAccountControl status for accounts for both enabling and disabling of 
    ''' accounts
    ''' </summary>
    ''' <param name="userType"></param>
    ''' <returns></returns>
    ''' <remarks>
    ''' ACCOUNT_ADMIN, ACCOUNT_RESOURCE and ACCOUNT_SERVICE types need a UF_NORMAL_ACCOUNT and are already addresses by the default value.
    ''' They are therefore not listed in the case statements.
    ''' </remarks>
    Private Function Get_userAccountControl(ByVal userType As String) As Integer
        Get_userAccountControl = UF_NORMAL_ACCOUNT ' Default enabled value will be set and only modified if additional parameters are needed

        Select Case userType 'Process the values for the FTE/Contractors and set the userAccountControl Value
            Case EMPLOYEE_TYPE_FTE
                'Get_userAccountControl = UF_DONT_EXPIRE_PASSWD + UF_NORMAL_ACCOUNT
                Get_userAccountControl = UF_NORMAL_ACCOUNT

            Case EMPLOYEE_TYPE_CONTRACTOR, EMPLOYEE_TYPE_CONTRACTOR_FP
                'Get_userAccountControl = UF_DONT_EXPIRE_PASSWD + UF_NORMAL_ACCOUNT
                Get_userAccountControl = UF_NORMAL_ACCOUNT

        End Select

    End Function


    ''' <summary>
    ''' This function determines if the custom default password must be used, if not then generates a random password
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Function Get_InitialPassword() As String
        Get_InitialPassword = Nothing

        If useCustomPassword Then ' Set the initial password to the custompassword if the condition is set to True
            Get_InitialPassword = customPassword
        Else
            ' Generate a random password for usage in Active Directory
            Get_InitialPassword = New Password_Generator().Generate()
        End If

    End Function

End Class
