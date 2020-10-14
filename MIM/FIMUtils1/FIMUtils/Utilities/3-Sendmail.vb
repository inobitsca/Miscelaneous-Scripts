Imports System
Imports System.Text
Imports System.Net.Mail
Imports Microsoft.MetadirectoryServices
Imports Microsoft.MetadirectoryServices.Logging
Imports CustomUtils.Utilities
Imports CustomUtils.Constants


Public Class SendMail
    Private Function Initialize() As Boolean

    End Function
    ''' <summary>
    ''' This subroutine function sends an Email to the determined manager once a new user is provisioned into the connector space. 
    ''' </summary>
    ''' <param name="mvEntry"></param>
    ''' <param name="userPassword"></param>
    ''' <remarks>
    ''' Please note that users will not appear in AD unless the an export of the connector space has been done
    ''' </remarks>
    Public Shared Sub SendNotificationEmail(ByVal mvEntry As MVEntry, _
                                      ByVal SMTPServer As String, _
                                      ByVal SMTPFrom As String, _
                                      ByVal SMTPBCC As String, _
                                      ByVal SMTPCC As String, _
                                      ByVal SMTPTo As String, _
                                      ByVal MailTemplate As String, _
                                      ByVal initialPassword As String, _
                                      ByVal defaultManagerEmail As String, _
                                      ByVal HelpdeskEmail As String)
        'First Name: First name as per SAR form
        'Last Name: Surname as per SAR form. 
        'Full name: Combination of first name space last name. (If Remedy complains about duplication include middle name.)
        'Login Prefix: nam (always lower case.)
        'AD Login: ACACIA login ID (Lower case)
        'Company: Nampak()
        'Client name: Can be obtained from the Company field in the SAR form ie Bevcan, Flexibles, NMS, etc. (Select from dropdown list.)
        'Client site: Can be obtained from the Company field in the SAR form ie Pine town, Rosslyn, Springs, Epping, etc. (Select from dropdown list.)
        'Email address: always lower case.
        'Telephone: 0117196300. (No international dialing codes.)
        'Dial code: This field stays blank.
        'Cell phone: (Only if one has been supplied.)
        'Job(Title)
        'Office(Location) : City()
        'Known name: first name.

        Dim managerEmail As String = Get_ManagerEmail(mvEntry, defaultManagerEmail)

        Dim SMTPSubject As String = Get_MailSubject(MailTemplate, mvEntry)
        Dim SMTPBody As String = Get_MailTemplate(MailTemplate, mvEntry, managerEmail, initialPassword)
        Dim SMTPMessage As New Net.Mail.MailMessage()

        Select Case MailTemplate
            Case Constants.Mail_Template_TerminateMGR
                SMTPTo = managerEmail

            Case Else
                Dim CCAddresses As String = SMTPCC
                If (Not CCAddresses = Nothing Or Not CCAddresses.Length < 1) AndAlso Not HelpdeskEmail = Nothing Then
                    CCAddresses += "," & managerEmail & _
                                  "," & HelpdeskEmail
                ElseIf Not HelpdeskEmail = Nothing Then
                    CCAddresses = managerEmail & "," & HelpdeskEmail
                Else
                    CCAddresses = managerEmail
                End If

                SMTPCC = CCAddresses
        End Select

        SMTPMessage.From = New Net.Mail.MailAddress(SMTPFrom)
        If Not SMTPTo = Nothing Then SMTPMessage.To.Add(SMTPTo)
        If Not SMTPCC = Nothing Then SMTPMessage.CC.Add(SMTPCC)
        If Not SMTPBCC = Nothing Then SMTPMessage.Bcc.Add(SMTPBCC)
        SMTPMessage.Subject = SMTPSubject
        SMTPMessage.Body = SMTPBody

        Dim SMTPSend As New Net.Mail.SmtpClient(SMTPServer)

        Try
            SMTPSend.Send(SMTPMessage)
        Catch ex As System.Net.Mail.SmtpFailedRecipientException
        Catch ex As Exception
            WriteToLog("Error Sending email to the Manager with the following error:" & ex.ToString, LOG_ERROR, False)
            Throw ex
        End Try
        WriteToLog(String.Format("Info: sending message of provisioning to manager: {0}", SMTPBody), LOG_INFO, False)


    End Sub

#Region "Mail Templates"

    ''' <summary>
    ''' This Function gets the message body with will be used by the SendNotificationEmail Function
    ''' </summary>
    ''' <param name="TemplateName"></param>
    ''' <param name="mvEntry"></param>
    ''' <param name="managerEmail"></param>
    ''' <param name="userPassword"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function Get_MailTemplate(ByVal TemplateName As String, ByVal mvEntry As MVEntry, ByVal managerEmail As String, ByVal userPassword As String) As String
        Get_MailTemplate = Nothing
        Select Case TemplateName
            Case Constants.Mail_Template_New
                Get_MailTemplate = NewEmployee_EmailMessagebody(mvEntry, managerEmail, userPassword)
            Case Constants.Mail_Template_Terminate
                Get_MailTemplate = AccountTermination_EmailMessagebody(mvEntry, managerEmail)
            Case Constants.Mail_Template_TerminateMGR
                Get_MailTemplate = AccountTerminationMGR_EmailMessagebody(mvEntry, managerEmail)
            Case Constants.Mail_Template_ChangeDetails
                Get_MailTemplate = EmployeeDetailsChange_EmailMessagebody(mvEntry, managerEmail)

        End Select

    End Function

    ''' <summary>
    ''' This Function builds the message body with will be used by the SendNotificationEmail Function
    ''' </summary>
    ''' <param name="mvEntry"></param>
    ''' <param name="managerEmail"></param>
    ''' <param name="userPassword"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function NewEmployee_EmailMessagebody(ByVal mvEntry As MVEntry, ByVal managerEmail As String, ByVal userPassword As String) As String
        NewEmployee_EmailMessagebody = Nothing
        Dim givenName As String = AttributeValue(mvEntry, "givenName")
        ' TODO: second name
        Dim sn As String = AttributeValue(mvEntry, "sn")
        Dim sAMAccountName As String = AttributeValue(mvEntry, "sAMAccountName")
        Dim company As String = AttributeValue(mvEntry, "company")
        Dim mail As String = AttributeValue(mvEntry, "mail")
        Dim phone As String = AttributeValue(mvEntry, "telephoneNumber")
        Dim mobile As String = AttributeValue(mvEntry, "mobile")
        Dim jobTitle As String = AttributeValue(mvEntry, "title")
        Dim city As String = AttributeValue(mvEntry, "l")
        Dim employeeId As String = AttributeValue(mvEntry, "employeeId") ' double check
        Dim displayName As String = AttributeValue(mvEntry, "displayName")

        NewEmployee_EmailMessagebody += "FIM Created ID " & AttributeValue(mvEntry, "sAMAccountName") & " for " & AttributeValue(mvEntry, "displayName") & "  - Please log request to complete the following tasks " + Chr(13) + Chr(13)

        NewEmployee_EmailMessagebody += "All tasks as stipulated in work instruction:" + Chr(13)
        NewEmployee_EmailMessagebody += "MC_INC_WORK_INSTRUCTION_USER_ADMIN_FOR_MIIS_CREATED_ACCOUNTS" + Chr(13) + Chr(13)

        NewEmployee_EmailMessagebody += "The following account has been created on Active Directory." + Chr(13)
        NewEmployee_EmailMessagebody += "The Account details are as follows: " + Chr(13)
        NewEmployee_EmailMessagebody += "First Name:           " & Chr(9) & givenName + Chr(13)
        NewEmployee_EmailMessagebody += "Surname:              " & Chr(9) & sn + Chr(13)
        NewEmployee_EmailMessagebody += "AD User Name:         " & Chr(9) & sAMAccountName + Chr(13)
        NewEmployee_EmailMessagebody += "Company:              " & Chr(9) & company + Chr(13)
        NewEmployee_EmailMessagebody += "Email Address:        " & Chr(9) & mail + Chr(13)
        NewEmployee_EmailMessagebody += "Office Phone:         " & Chr(9) & phone + Chr(13)
        NewEmployee_EmailMessagebody += "Mobile Phone:         " & Chr(9) & mobile + Chr(13)
        NewEmployee_EmailMessagebody += "Position:             " & Chr(9) & jobTitle + Chr(13)
        NewEmployee_EmailMessagebody += "City:                 " & Chr(9) & city + Chr(13)
        NewEmployee_EmailMessagebody += "Employee ID:          " & Chr(9) & employeeId + Chr(13)
        NewEmployee_EmailMessagebody += "Initial Password:     " & Chr(9) & userPassword + Chr(13)
        NewEmployee_EmailMessagebody += "Manager Email Address:" & Chr(9) & managerEmail + Chr(13)
        NewEmployee_EmailMessagebody += "Display Name:         " & Chr(9) & displayName + Chr(13)
        NewEmployee_EmailMessagebody += Chr(13)
        NewEmployee_EmailMessagebody += "Please Note that the account may take up to 2 hours before it reflects within Active Directory"

    End Function

    ''' <summary>
    ''' This Function builds the message body with will be used by the SendNotificationEmail Function
    ''' </summary>
    ''' <param name="mvEntry"></param>
    ''' <param name="managerEmail"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function AccountTermination_EmailMessagebody(ByVal mvEntry As MVEntry, ByVal managerEmail As String) As String
        AccountTermination_EmailMessagebody = Nothing

        Dim givenName As String = AttributeValue(mvEntry, "givenName")
        ' TODO: second name
        Dim sn As String = AttributeValue(mvEntry, "sn")
        Dim sAMAccountName As String = AttributeValue(mvEntry, "sAMAccountName")
        Dim company As String = AttributeValue(mvEntry, "company")
        Dim mail As String = AttributeValue(mvEntry, "mail")
        Dim phone As String = AttributeValue(mvEntry, "telephoneNumber")
        Dim mobile As String = AttributeValue(mvEntry, "mobile")
        Dim jobTitle As String = AttributeValue(mvEntry, "title")
        Dim city As String = AttributeValue(mvEntry, "l")
        Dim employeeId As String = AttributeValue(mvEntry, "employeeId") ' double check
        Dim displayName As String = AttributeValue(mvEntry, "displayName")
        Dim departureDate As DateTime = DateTime.Parse(mvEntry("employeeDepartureDate").StringValue)

        Select Case mvEntry.ObjectType.ToLower
            Case "ssoperson"
                AccountTermination_EmailMessagebody += "This account is set for expiry on the " & departureDate.ToString("dd'/'MM'/'yyyy")
            Case "person"
                AccountTermination_EmailMessagebody += "Your HR practitioner has set this account to expire on the " & departureDate.ToString("dd'/'MM'/'yyyy")
        End Select

        AccountTermination_EmailMessagebody += "The Account details are as follows: " + Chr(13)
        AccountTermination_EmailMessagebody += "First Name:           " & Chr(9) & givenName + Chr(13)
        AccountTermination_EmailMessagebody += "Surname:              " & Chr(9) & sn + Chr(13)
        AccountTermination_EmailMessagebody += "AD User Name:         " & Chr(9) & sAMAccountName + Chr(13)
        AccountTermination_EmailMessagebody += "Company:              " & Chr(9) & company + Chr(13)
        AccountTermination_EmailMessagebody += "Email Address:        " & Chr(9) & mail + Chr(13)
        AccountTermination_EmailMessagebody += "Office Phone:         " & Chr(9) & phone + Chr(13)
        AccountTermination_EmailMessagebody += "Mobile Phone:         " & Chr(9) & mobile + Chr(13)
        AccountTermination_EmailMessagebody += "Position:             " & Chr(9) & jobTitle + Chr(13)
        AccountTermination_EmailMessagebody += "City:                 " & Chr(9) & city + Chr(13)
        AccountTermination_EmailMessagebody += "Employee ID:          " & Chr(9) & employeeId + Chr(13)
        AccountTermination_EmailMessagebody += "Manager Email Address:" & Chr(9) & managerEmail + Chr(13)
        AccountTermination_EmailMessagebody += "Display Name:         " & Chr(9) & displayName + Chr(13)

    End Function

    Public Shared Function AccountTerminationMGR_EmailMessagebody(ByVal mvEntry As MVEntry, ByVal managerEmail As String) As String
        AccountTerminationMGR_EmailMessagebody = Nothing

        Dim givenName As String = AttributeValue(mvEntry, "givenName")
        ' TODO: second name
        Dim sn As String = AttributeValue(mvEntry, "sn")
        Dim sAMAccountName As String = AttributeValue(mvEntry, "sAMAccountName")
        Dim company As String = AttributeValue(mvEntry, "company")
        Dim mail As String = AttributeValue(mvEntry, "mail")
        Dim phone As String = AttributeValue(mvEntry, "telephoneNumber")
        Dim mobile As String = AttributeValue(mvEntry, "mobile")
        Dim jobTitle As String = AttributeValue(mvEntry, "title")
        Dim city As String = AttributeValue(mvEntry, "l")
        Dim employeeId As String = AttributeValue(mvEntry, "employeeId") ' double check
        Dim displayName As String = AttributeValue(mvEntry, "displayName")
        Dim departureDate As DateTime = DateTime.Parse(mvEntry("employeeDepartureDate").StringValue)

        Select Case mvEntry.ObjectType.ToLower
            Case "ssoperson"
                AccountTerminationMGR_EmailMessagebody += "This suboordinate account is set for expiry on the " & departureDate.ToString("dd'/'MM'/'yyyy")
            Case "person"
                AccountTerminationMGR_EmailMessagebody += "Your HR practitioner has set this suboordinate account to expire on the " & departureDate.ToString("dd'/'MM'/'yyyy")
        End Select

        AccountTerminationMGR_EmailMessagebody += "The User (name/account) is listed as your subordinate and their account is due to expire. " & _
                                                "If you still require the account to be active advise your HR department to extend the account on the forefront identity management portal " & _
                                                " for contractors or via dynamique for employees paid through Nampak payroll."

        AccountTerminationMGR_EmailMessagebody += "The Account details are as follows: " + Chr(13)
        AccountTerminationMGR_EmailMessagebody += "First Name:           " & Chr(9) & givenName + Chr(13)
        AccountTerminationMGR_EmailMessagebody += "Surname:              " & Chr(9) & sn + Chr(13)
        AccountTerminationMGR_EmailMessagebody += "AD User Name:         " & Chr(9) & sAMAccountName + Chr(13)
        AccountTerminationMGR_EmailMessagebody += "Company:              " & Chr(9) & company + Chr(13)
        AccountTerminationMGR_EmailMessagebody += "Email Address:        " & Chr(9) & mail + Chr(13)
        AccountTerminationMGR_EmailMessagebody += "Office Phone:         " & Chr(9) & phone + Chr(13)
        AccountTerminationMGR_EmailMessagebody += "Mobile Phone:         " & Chr(9) & mobile + Chr(13)
        AccountTerminationMGR_EmailMessagebody += "Position:             " & Chr(9) & jobTitle + Chr(13)
        AccountTerminationMGR_EmailMessagebody += "City:                 " & Chr(9) & city + Chr(13)
        AccountTerminationMGR_EmailMessagebody += "Employee ID:          " & Chr(9) & employeeId + Chr(13)
        AccountTerminationMGR_EmailMessagebody += "Manager Email Address:" & Chr(9) & managerEmail + Chr(13)
        AccountTerminationMGR_EmailMessagebody += "Display Name:         " & Chr(9) & displayName + Chr(13)

    End Function

    Public Shared Function EmployeeDetailsChange_EmailMessagebody(ByVal mvEntry As MVEntry, ByVal managerEmail As String) As String

        EmployeeDetailsChange_EmailMessagebody = Nothing

        Dim sAMAccountName As String = AttributeValue(mvEntry, "sAMAccountName")
        Dim employeeId As String = AttributeValue(mvEntry, "employeeId") ' double check
        Dim displayName As String = AttributeValue(mvEntry, "displayName")

        EmployeeDetailsChange_EmailMessagebody += "Account details for " & AttributeValue(mvEntry, "displayName") & ", ID: " & AttributeValue(mvEntry, "sAMAccountName") & " have been updated, please update the information on Remedy." + Chr(13) + Chr(13)

        EmployeeDetailsChange_EmailMessagebody += "The Account details are as follows: " + Chr(13)
        EmployeeDetailsChange_EmailMessagebody += "Employee ID:          " & Chr(9) & employeeId + Chr(13)
        EmployeeDetailsChange_EmailMessagebody += "AD User Name:         " & Chr(9) & sAMAccountName + Chr(13) + Chr(13)

        EmployeeDetailsChange_EmailMessagebody += "The following list account details have been changed:" + Chr(13)

        For Each line As String In mvEntry("ChangeTracker").Values.ToStringArray
            If line.EndsWith("Changed") Then
                Dim ChangedField = line.Substring(0, line.IndexOf(":") - 1)
                Dim Changes() As String = line.Substring(ChangedField.Length + 1).Split(",")
                EmployeeDetailsChange_EmailMessagebody += "Field that has changed:" & Chr(9) & ChangedField + Chr(13)
                EmployeeDetailsChange_EmailMessagebody += "Old Value:" & Chr(9) & Changes.GetValue(1).ToString + Chr(13)
                EmployeeDetailsChange_EmailMessagebody += "New Value:" & Chr(9) & Changes.GetValue(0).ToString + Chr(13)
            End If

            EmployeeDetailsChange_EmailMessagebody += Chr(13)
        Next

    End Function

#End Region

#Region "Mail Subject Section"

    ''' <summary>
    ''' This Function gets the message subject with will be used by the SendNotificationEmail Function
    ''' </summary>
    ''' <param name="MailTemplate"></param>
    ''' <param name="mvEntry"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function Get_MailSubject(ByVal MailTemplate As String, ByVal mventry As MVEntry) As String
        Get_MailSubject = Nothing

        Select Case MailTemplate
            Case Constants.Mail_Template_New
                Get_MailSubject = "FIM Created ID " & AttributeValue(mventry, "sAMAccountName") & " for " & AttributeValue(mventry, "displayName")

            Case Constants.Mail_Template_Terminate
                Dim DepartureDate As DateTime = DateTime.Parse(mventry("employeeDepartureDate").StringValue)
                Get_MailSubject = "Your Account " & AttributeValue(mventry, "sAMAccountName") & _
                                  " will be expiring on " & DepartureDate.ToString("dd'/'MM'/'yyyy") & _
                                  " and will be disabled after this date."
            Case Constants.Mail_Template_TerminateMGR
                Dim DepartureDate As DateTime = DateTime.Parse(mventry("employeeDepartureDate").StringValue)
                Get_MailSubject = "Your Suboordinate’s account " & AttributeValue(mventry, "sAMAccountName") & _
                                  " will be expiring on " & DepartureDate.ToString("dd'/'MM'/'yyyy") & _
                                  " and will be disabled after this date."
            Case Constants.Mail_Template_ChangeDetails
                Get_MailSubject = "User information for user " & AttributeValue(mventry, "displayName") + ", ID: " & AttributeValue(mventry, "sAMAccountName") & " have changed"


        End Select
    End Function
#End Region

    ''' <summary>
    ''' This function checks if an attribute has a value, then returns the value to the calling function.
    ''' </summary>
    ''' <param name="mvEntry"></param>
    ''' <param name="attribute"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Shared Function AttributeValue(ByVal mvEntry As MVEntry, ByVal attribute As String) As String
        AttributeValue = String.Empty
        Try
            If (mvEntry(attribute).IsPresent) Then
                AttributeValue = mvEntry(attribute).Value
            Else
                WriteToLog(String.Format("Warning: Attribute {0} is not present", attribute), LOG_WARN, False)

            End If
        Catch ex As Exception
            WriteToLog(String.Format("Error: Exception while trying to read {0}: {1}", attribute, ex.Message), LOG_ERROR, True)
        End Try

    End Function

    ''' <summary>
    ''' This function get the manager email for sending the manager an email after the user objects have been provisioned
    ''' </summary>
    ''' <param name="mventry"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function Get_ManagerEmail(ByVal mventry As MVEntry, ByVal defaultManagerEmail As String) As String
        'Get_ManagerEmail = Nothing
        Get_ManagerEmail = defaultManagerEmail ' Sets the default return value to the default manager value. This value will be returned if no other values are found in the metaverse

        'Throw New Exception("Email: " & Get_ManagerEmail)

        Dim TrimChar() As Char = New Char() {CType("0", Char)}

        Dim Get_Manager() As MVEntry = Nothing ' An Array of MVEntries that will used to search for the manager email address

        Try
            Get_Manager = Utils.FindMVEntries("employeeID", mventry("managerID").Value.ToString, 1) ' First try with the base managerID value

            If Get_Manager.Length = 0 Then ' If no values were found in the first instance, try again with the leading zero's trimmed away
                Get_Manager = Utils.FindMVEntries("employeeID", mventry("managerID").Value.TrimStart(TrimChar).ToString, 1)
            End If

            If Get_Manager.Length > 0 Then ' If there are more than 0 entries, then use the first entry in the list
                Get_ManagerEmail = Get_Manager(0).Item("mail").Value
            End If

        Catch ex As Exception ' catch the exception, but don't do anything further as the default manager value will already be returned
        End Try

    End Function
End Class
