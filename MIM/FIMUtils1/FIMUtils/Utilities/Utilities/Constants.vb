
Public Class Constants
    ' Email Constants 
    Public Const Mail_Template_New As String = "NewEmployee"
    Public Const Mail_Template_Terminate As String = "TerminateEmployee"
    Public Const Mail_Template_ChangeDetails As String = "ChangeEmployeeDetails"
    Public Const Mail_Template_TerminateMGR As String = "TerminateEmployeeMGR"

    ' Constants for employeeStatus
    Public Const EMPLOYEE_ACTIVE_FP As Object = "Active" '3
    Public Const EMPLOYEE_ACTIVE As Object = "Provisioned" '3

    Public Const EMPLOYEE_LEAVE As Object = "Leave" '1
    Public Const EMPLOYEE_RETIRED As Object = "Retired" '2
    Public Const EMPLOYEE_DISABLED_FP As Object = "Disabled"
    Public Const EMPLOYEE_DISABLED As Object = "0"

    ' Constants for employeeType
    Public Const EMPLOYEE_TYPE_FTE As Object = "P"
    Public Const EMPLOYEE_TYPE_CONTRACTOR As Object = "C"
    Public Const EMPLOYEE_TYPE_CONTRACTOR_FP As Object = "Contractor"

    ' Constants for accountType
    Public Const ACCOUNT_ADMIN As Object = "Admin Account"
    Public Const ACCOUNT_SERVICE As Object = "Service Account"
    Public Const ACCOUNT_RESOURCE As Object = "Resource Account"
    Public Const ACCOUNT_SHARED As Object = "Shared Account"

    ' Constant to load the XML file 
    Public Const SCENARIO_XML_CONFIG As String = "\Extensions.xml"

    ' Declaration of Constants for the Active Directory "userAccountControl" bitmask. Taken from LMaccess.h
    Public Const UF_SCRIPT As Object = &H1
    Public Const UF_ACCOUNTDISABLE As Object = &H2
    Public Const UF_HOMEDIR_REQUIRED As Object = &H8
    Public Const UF_LOCKOUT As Object = &H10
    Public Const UF_PASSWD_NOTREQD As Object = &H20
    Public Const UF_PASSWD_CANT_CHANGE As Object = &H40
    Public Const UF_ENCRYPTED_TEXT_PASSWORD_ALLOWED As Object = &H80
    Public Const UF_TEMP_DUPLICATE_ACCOUNT As Object = &H100
    Public Const UF_NORMAL_ACCOUNT As Object = &H200
    Public Const UF_DONT_EXPIRE_PASSWD As Object = &H10000
    Public Const UF_MNS_LOGON_ACCOUNT As Object = &H20000
    Public Const UF_SMARTCARD_REQUIRED As Object = &H40000
    Public Const UF_TRUSTED_FOR_DELEGATION As Object = &H80000
    Public Const UF_NOT_DELEGATED As Object = &H100000
    Public Const UF_USE_DES_KEY_ONLY As Object = &H200000
    Public Const UF_DONT_REQUIRE_PREAUTH As Object = &H400000
    Public Const UF_PASSWORD_EXPIRED As Object = &H800000
    Public Const UF_TRUSTED_TO_AUTHENTICATE_FOR_DELEGATION As Object = &H1000000

    ' Logging levels - corresponds with logging.xml
    Public Const LOG_CRIT As Object = 0
    Public Const LOG_ERROR As Object = 1
    Public Const LOG_WARN As Object = 2
    Public Const LOG_INFO As Object = 3

    ' sAMAccount Constant Values
    Public Const MAX_SAM_GIVENNAME As Integer = 2
    Public Const MAX_SAM_SURNAME As Integer = 3
    Public Const MAX_SAM_LENGTH As Integer = 20
End Class
