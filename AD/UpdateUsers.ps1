# UpdateUsers.ps1
# PowerShell program to update Active Directory users from the information in a
# Microsoft Excel spreadsheet. Only single-valued string attributes supported.
# Author: Richard Mueller
# PowerShell Version 1.0
# September 12, 2011

Trap
{
    If ("$_".StartsWith("Cannot load COM type Excel.Application"))
    {
        "Excel application not found, program aborted"
        Add-Content -Path $LogFile -Value "## Excel application not found"
        Add-Content -Path $LogFile -Value "   $_"
        Add-Content -Path $LogFile -Value $("Program aborted: " + (Get-Date).ToString())
        Break
    }
    If (("$_".StartsWith("Exception has been thrown")) -and ($Step -eq "4"))
    {
        "Excel spreadsheet not found, program aborted"
        Add-Content -Path $LogFile -Value "## Excel spreadsheet not found: $ExcelPath"
        Add-Content -Path $LogFile -Value "   $_"
        Add-Content -Path $LogFile -Value $("Program aborted: " + (Get-Date).ToString())
        Break
    }
    If ("$_".StartsWith("The server is not operational"))
    {
        "Domain Controller not found, program aborted"
        Add-Content -Path $LogFile -Value "## Domain Controller not found"
        Add-Content -Path $LogFile -Value "   $_"
        Add-Content -Path $LogFile -Value $("Program aborted: " + (Get-Date).ToString())
        Break
    }
    If ("$_".StartsWith("The directory service is unavailable"))
    {
        "Active Directory not found, program aborted"
        Add-Content -Path $LogFile -Value "## Active Directory not found"
        Add-Content -Path $LogFile -Value "   $_"
        Add-Content -Path $LogFile -Value $("Program aborted: " + (Get-Date).ToString())
        Break
    }
    If ("$_".StartsWith("The specified domain"))
    {
        "Domain not found, program aborted"
        Add-Content -Path $LogFile -Value "## Domain not found"
        Add-Content -Path $LogFile -Value "   $_"
        Add-Content -Path $LogFile -Value $("Program aborted: " + (Get-Date).ToString())
        Break
    }
    "Unexpected error: $_"
    Add-Content -Path $LogFile -Value "## Unexpected error: $_"
    Add-Content -Path $LogFile -Value "   Step: $Step"
    Break
}

Function CleanUp
{
    Trap
    {
        "Error during cleanup: $_"
        Add-Content -Path $LogFile -Value "## Error during cleanup: $_"
        $Script:Errors = $Script:Errors + 1
        Continue
    }
    # Function to release Excel objects from memory.
    Do {$x = [System.Runtime.InteropServices.Marshal]::ReleaseComObject($Columns)} While ($x -gt -1)
    Do {$x = [System.Runtime.InteropServices.Marshal]::ReleaseComObject($Rows)} While ($x -gt -1)
    Do {$x = [System.Runtime.InteropServices.Marshal]::ReleaseComObject($Range)} While ($x -gt -1)
    Do {$x = [System.Runtime.InteropServices.Marshal]::ReleaseComObject($Sheet)} While ($x -gt -1)
    Do {$x = [System.Runtime.InteropServices.Marshal]::ReleaseComObject($Worksheets)} While ($x -gt -1)
    $Workbook.Close($False)

    Do {$x = [System.Runtime.InteropServices.Marshal]::ReleaseComObject($Workbook)} While ($x -gt -1)
    Do {$x = [System.Runtime.InteropServices.Marshal]::ReleaseComObject($Workbooks)} While ($x -gt -1)
    $Excel.Quit()
    Do {$x = [System.Runtime.InteropServices.Marshal]::ReleaseComObject($Excel)} While ($x -gt -1)
}

# Specify paths to spreadsheet and log file.
$Script:Errors = 0
$Step = "1"
$ExcelPath = "c:\scripts\UpdateUsers.xls"
$LogFile = "c:\scripts\UpdateUsers.log"
Write-Host "Please Standby..."

# Add to the log file.
$Step = "2"
Add-Content -Path $LogFile -Value "------------------------------------------------" -ErrorAction Stop
Add-Content -Path $LogFile -Value "UpdateUsers.ps1 Version 1.0 (September 12, 2011)"
Add-Content -Path $LogFile -Value $("Started: " + (Get-Date).ToString())
Add-Content -Path $LogFile -Value "Spreadsheet: $ExcelPath"
Add-Content -Path $LogFile -Value "Log file: $LogFile"
$Step = "3"

# Open specified Excel spreadsheet.
$Excel = New-Object -ComObject "Excel.Application"
$Workbooks = $Excel.Workbooks
$Step = "4"
$Workbook = $Workbooks.Open($ExcelPath)
$Worksheets = $Workbook.Worksheets
$Sheet = $Worksheets.Item(1)
$Range = $Sheet.UsedRange
$Rows = $Range.Rows
$Columns = $Range.Columns
$Step = "5"

# Hash table of attribute syntaxes.
# The LDAP display names will be read from the spreadsheet.
# The corresponding syntaxes will be read from the Schema container.
$Attributes = @{}

# Array of spreadsheet column headings.
$Cols = @()
$Step = "6"

# Read attribute LDAP Display Names from the first row of the spreadsheet.
$ID = 0
For ($k = 1; $k -le $Columns.Count; $k = $k + 1)
{
    # Retrieve column heading, the lDAPDisplayName of an attribute.
    $Value = $Sheet.Cells.Item(1, $k).Text
    # Keep track of all column headings.
    $Cols += $Value
    # Skip duplicates in hash table.
    If ($Attributes.ContainsKey($Value) -eq $False)
    {
        # Default is "NotFound", until found in the AD Schema.
        $Attributes.Add($Value, "NotFound")
    }
    # Keep track of which column uniquely identifies users.
    If ($Value.ToLower() -eq "distinguishedname") {$ID = $k}
    If (($Value.ToLower() -eq "samaccountname") -and ($ID -eq 0)) {$ID = $k}
    # This script cannot be used to rename users.
    If ($value.ToLower() -eq "cn")
    {
        Add-Content -Path $LogFile -Value "## This script cannot be used to rename users"
        Add-Content -Path $LogFile -Value "   Do not specify the cn attribute in the spreadsheet"
        Add-Content -Path $LogFile -Value $("Program aborted: " + (Get-Date).ToString())
        CleanUp
        Return "Program aborted: cn attribute found in spreadsheet" `
            + "`nSee log file: $LogFile"
    }
}
$Step = "7"

If ($ID -eq 0)
{
    Add-Content -Path $LogFile -Value "## No column found to identify users"
    Add-Content -Path $LogFile -Value "   One column must be distinguishedName or sAMAccountName"
    Add-Content -Path $LogFile -Value $("Program aborted: " + (Get-Date).ToString())
    CleanUp
    Return "Program aborted: No column found in spreadsheet to identify users" `
        + "`nSee log file: $LogFile"
}

# Create filter to query for attributes in the schema.
$Attrs = $Attributes.Keys
$Filter = "(&(objectCategory=AttributeSchema)(|"
ForEach ($Attr In $Attrs)
{
    $Filter = $Filter + "(lDAPDisplayName=$Attr)"
}
$Filter = $Filter + "))"
$Step = "8"

$RootDSE = [System.DirectoryServices.DirectoryEntry]([ADSI]"LDAP://RootDSE")
$Domain = $RootDSE.Get("defaultNamingContext")
$Schema = $RootDSE.Get("schemaNamingContext")
$Step = "9"

# Use the NameTranslate object.
$objTrans = New-Object -comObject "NameTranslate"
$objNT = $objTrans.GetType()

# Initialize NameTranslate by locating the Global Catalog.
$objNT.InvokeMember("Init", "InvokeMethod", $Null, $objTrans, (3, $Null))
$Step = "10"

# Retrieve NetBIOS name of the current domain.
$objNT.InvokeMember("Set", "InvokeMethod", $Null, $objTrans, (1, "$Domain"))
$NetBIOSDomain = $objNT.InvokeMember("Get", "InvokeMethod", $Null, $objTrans, 3)
Add-Content -Path $LogFile -Value "NetBIOS name of domain: $NetBIOSDomain"
$Step = "11"

$Searcher = New-Object System.DirectoryServices.DirectorySearcher
$Searcher.SearchRoot = [ADSI]"LDAP://$Schema"
$Searcher.PageSize = 200
$Searcher.SearchScope = "subtree"

$Searcher.PropertiesToLoad.Add("lDAPDisplayName") > $Null
$Searcher.PropertiesToLoad.Add("attributeSyntax") > $Null
$Searcher.PropertiesToLoad.Add("isSingleValued") > $Null
$Searcher.PropertiesToLoad.Add("systemFlags") > $Null

# Filter on specified attributes.
$Searcher.Filter = $Filter
$Step = "12"

# Query Active Directory.
$Results = $Searcher.FindAll()

# Enumerate recordset.
ForEach ($Result In $Results)
{
    # Retrieve properties of attributes.
    $Name = $Result.Properties.Item("lDAPDisplayName")[0]
    $SysFlags = $Result.Properties.Item("systemFlags")[0]
    $SyntaxNum = $Result.Properties.Item("attributeSyntax")[0]
    $SingleValued = $Result.Properties.Item("isSingleValued")[0]

    # Only single-valued string attributes supported by this version of the program.
    Switch ($SyntaxNum)
    {
        "2.5.5.12" {$Syntax = "String"}
        Default {$Syntax = "NotSupported"}
    }
    If ($Name.ToLower() -eq "distinguishedname") {$Syntax = "DN"}
    If (($SysFlags -band 4) -ne 0)
    {
        $Attributes[$Name] = "Constructed"
    }
    Else
    {
        If ($SingleValued -eq $True)
        {
            $Attributes[$Name] = $Syntax
        }
        Else
        {
            $Attributes[$Name] = "NotSupported"
        }
    }
}
$Step = "13"

# Check if any attributes not found or have unsupported syntax.
$Found = $True
ForEach ($Attr In $Attrs)
{
    $Syntax = $Attributes[$Attr]
    If ($Syntax -eq "NotFound")
    {
        Add-Content -Path $LogFile -Value "## Attribute $Attr not found in schema"
        "Attribute $Attr not found in schema"
        $Found = $False
    }
    If ($Syntax -eq "NotSupported")
    {
        Add-Content -Path $LogFile -Value "## Attribute $Attr has a syntax that is not supported"
        "Attribute $Attr has a syntax that is not supported"
        $Found = $False
    }
    If ($Syntax -eq "Constructed")
    {
        Add-Content -Path $LogFile -Value "## Attribute $Attr is operational, so is not supported"
        "Attribute $Attr is operational, so is not supported"
        $Found = $False
    }
}
$Step = "14"

If ($Found -eq $False)
{
    Add-Content -Path $LogFile -Value $("Program aborted: " + (Get-Date).ToString())
    CleanUp
    Return "Program aborted" `
        + "`nSee log file: $LogFile"
}

# Read remaining rows of the spreadsheet, until the first blank value is found
# in the column that identifies users.
$Step = "15"
$Script:Updated = 0
$Script:Unchanged = 0
$j = 2
Do {
    # Retieve ID value for the user first.
    $Value = $Sheet.Cells.Item($J, $ID).Text
    $Found = $False
    $Step = "16"
    If ($Cols[$ID - 1] -eq "distinguishedname")
    {
        # Any forward slash characters must be escaped.
        $DN = $Value.Replace("/", "\/")
        # Bind to the user object.
        # If user not found, $User.Name will be $Null.
        $User = [ADSI]"LDAP://$DN"
        If ($User.Name -ne $Null)
        {
            $Found = $True
        }
    }
    $Step = "17"
    If ($Cols[$ID - 1] -eq "samaccountname")
    {
        Trap
        {
            Write-Host ""
            "Error translating name: $_"
            Add-Content -Path $LogFile -Value "## Error translating name $Value"
            Add-Content -Path $LogFile -Value "   Description: $_"
            $Script:Errors = $Script:Errors + 1
            Continue
        }
        # Convert sAMAccountName to distinguishedName.
        $DN = ""
        $Step = "18"
        $objNT.InvokeMember("Set", "InvokeMethod", $Null, $objTrans, (3, "$NetBIOSDomain$Value"))
        $DN = $objNT.InvokeMember("Get", "InvokeMethod", $Null, $objTrans, 1)
        $Step = "19"
        If ($DN -ne "")
        {
            $Step = "20"
            # Any forward slash characters must be escaped.
            $DN = $DN.Replace("/", "\/")
            # Bind to the user object.
            $User = [ADSI]"LDAP://$DN"
            $Found = $True
        }
    }
    If ($Found -eq $True)
    {
        $Step = "21"
        # Read remaining values for this user.
        $Changed = $False
        For ($k = 1; $k -le $Columns.Count; $k = $k + 1)
        {
            # Skip the identifying column.
            If ($k -ne $ID)
            {
                $Step = "22"
                # Retrieve attribute name for this column from array.
                $AttrName = $Cols[$k - 1]
                # Retrieve attribute syntax from hash table.
                $Syntax = $Attributes[$AttrName]
                $Step = "23"
                # Retrieve attribute value for this user.
                $Value = $Sheet.Cells.Item($j, $k).Text
                # Skip blank values.
                If ($Value -ne "")
                {
                    If ($Syntax -eq "String")
                    {
                        Trap
                        {
                            If ("$_".StartsWith("The directory property cannot be found"))
                            {
                                Continue
                            }
                            Else
                            {
                                Write-Host ""
                                "Error retrieving value from Active Directory: $_"
                                Add-Content -Path $LogFile -Value "## Error retrieving $AttrName for user $DN"
                                Add-Content -Path $LogFile -Value "   Description: $_"
                                $Script:Errors = $Script:Errors + 1
                                Continue
                            }
                        }
                        $Step = "24"
                        # Single-valued string attribute.
                        # Retrieve existing value.
                        $OldValue = ""
                        $OldValue = $User.Get($AttrName)
                        # Check if existing value to be deleted.
                        If ($Value.ToLower() -eq ".delete")
                        {
                            If ($OldValue -ne "")
                            {
                                If ($AttrName.ToLower -eq "samaccountname")
                                {
                                    Add-Content -Path $LogFile -Value `
                                        "## Mandatory attribute sAMAccountName cannot be cleared for user: $DN"
                                    $Script:Errors = $Script:Errors + 1
                                }
                                Else
                                {
                                    Trap
                                    {
                                        Write-Host ""
                                        "Error deleting value from Active Directory: $_"
                                        Add-Content -Path $LogFile -Value "## Error deleting $AttrName for user $DN"
                                        Add-Content -Path $LogFile -Value "   Description: $_"
                                        $Script:Errors = $Script:Errors + 1
                                        Continue
                                    }
                                    $Step = "25"
                                    # Make the attribute value "not set".
                                    $User.PutEx(1, $AttrName, 0)
                                    $Changed = $True
                                }
                            }
                        }
                        Else
                        {
                            $Step = "26"
                            # Check if new value from spreadsheet different.
                            If ($Value -ne $OldValue)
                            {
                                Trap
                                {
                                    Write-Host ""
                                    "Error assigning value from Active Directory: $_"
                                    Add-Content -Path $LogFile -Value "## Error assigning $AttrName for user $DN"
                                    Add-Content -Path $LogFile -Value "   Description: $_"
                                    $Script:Errors = $Script:Errors + 1
                                    Continue
                                }
                                # Assign the new value to the attribute.
                                $User.Put($AttrName, $Value)
                                $Changed = $True
                            }
                        }
                    }
                    Else
                    {
                        # Unexpected error.
                        Add-Content -Path $LogFile -Value `
                            "## Unexpected syntax: $Syntax for attribute $AttrName for user $DN"
                        $Script:Errors = $Script:Errors + 1
                    }
                }
            }
        }
        If ($Changed -eq $True)
        {
            Trap
            {
                Write-Host ""
                "Error saving to Active Directory: $_"
                Add-Content -Path $LogFile -Value "## Error saving to AD for user $DN"
                Add-Content -Path $LogFile -Value "   Description: $_"
                $Script:Errors = $Script:Errors + 1
                $Script:Updated = $Script:Updated - 1
                Continue
            }
            $User.SetInfo()
            Add-Content -Path $LogFile -Value "Update user: $DN"
            Write-Host "." -NoNewLine
            $Script:Updated = $Script:Updated + 1
        }
        Else
        {
            Add-Content -Path $LogFile -Value "User unchanged: $DN"
            Write-Host "." -NoNewLine
            $Script:Unchanged = $Script:Unchanged + 1
        }
    }
    Else
    {
        Add-Content -Path $LogFile -Value "## User not found: $Value"
        Write-Host "." -NoNewLine
        $Script:Errors = $Script:Errors + 1
    }
    $j = $J + 1
} Until ($Sheet.Cells.Item($j, $ID).Text -eq "")
$Step = "27"

CleanUp
Add-Content -Path $LogFile -Value $("Finished: " + (Get-Date).ToString())
Add-Content -Path $LogFile -Value "Number of users updated: $Script:Updated"
Add-Content -Path $LogFile -Value "Number of users unchanged: $Script:Unchanged"
Add-Content -Path $LogFile -Value "Number of errors: $Script:Errors"

Write-Host ""
"Done"
"Number of errors: $Script:Errors"
"See log file: $LogFile"