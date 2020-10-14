#Test Variables
$email1 = "Primary@domain.com"
$result = ""

#Menu Options
$op1 = 'Change the Primary Address'
$op2 = 'Add a secondary Address'
$op3 = 
$op4 = 

# Init PowerShell Gui
Add-Type -AssemblyName System.Windows.Forms
# Create a new form
$AddressForm                    = New-Object system.Windows.Forms.Form
# Define the size, title and background color
$AddressForm.ClientSize         = '500,300'
$AddressForm.text               = "Email Address Management"
$AddressForm.BackColor          = "#ffffff"

# Create a Title for our form. We will use a label for it.
$TitleOperationChoice                           = New-Object system.Windows.Forms.Label
# The content of the label
$TitleOperationChoice.text                      = "Email Address Management"
# Make sure the label is sized the height and length of the content
$TitleOperationChoice.AutoSize                  = $true
# Define the minial width and height (not nessary with autosize true)
$TitleOperationChoice.width                     = 25
$TitleOperationChoice.height                    = 10
# Position the element
$TitleOperationChoice.location                  = New-Object System.Drawing.Point(20,20)
# Define the font type and size
$TitleOperationChoice.Font                      = 'Microsoft Sans Serif,13'
# Other elemtents
$Description                     = New-Object system.Windows.Forms.Label
$Description.text                = "Please Choose you option below."
$Description.AutoSize            = $false
$Description.width               = 450
$Description.height              = 35
$Description.location            = New-Object System.Drawing.Point(20,50)
$Description.Font                = 'Microsoft Sans Serif,10'
$Status                   = New-Object system.Windows.Forms.Label
$Status.text              = "Please enter the username below"
$Status.AutoSize          = $true
$Status.location          = New-Object System.Drawing.Point(20,170)
$Status.Font              = 'Microsoft Sans Serif,10'


#>

#Dropdown

#TextBoxLable
$OperationChoiceLabel                = New-Object system.Windows.Forms.Label
$OperationChoiceLabel.text           = "Select Option:"
$OperationChoiceLabel.AutoSize       = $true
$OperationChoiceLabel.width          = 25
$OperationChoiceLabel.height         = 20
$OperationChoiceLabel.location       = New-Object System.Drawing.Point(20,130)
$OperationChoiceLabel.Font           = 'Microsoft Sans Serif,10,style=Bold'
$OperationChoiceLabel.Visible        = $True
$AddressForm.Controls.Add($OperationChoiceLabel)

$OperationChoice                     = New-Object system.Windows.Forms.ComboBox
$OperationChoice.text                = "Choose"
$OperationChoice.width               = 200
$OperationChoice.autosize            = $true
$OperationChoice.Visible             = $true        
# Add the items in the dropdown list
@($op1,$op2,$op3,$op4) | ForEach-Object {[void] $OperationChoice.Items.Add($_)}
# Select the default value
$OperationChoice.SelectedIndex       = 0
$OperationChoice.location            = New-Object System.Drawing.Point(150,130)
$OperationChoice.Font                = 'Microsoft Sans Serif,10'
$AddressForm.Controls.Add($OperationChoice)



#TextBoxLable
$SAMNameLabel                = New-Object system.Windows.Forms.Label
$SAMNameLabel.text           = "samAccountName:"
$SAMNameLabel.AutoSize       = $true
$SAMNameLabel.width          = 25
$SAMNameLabel.height         = 20
$SAMNameLabel.location       = New-Object System.Drawing.Point(20,200)
$SAMNameLabel.Font           = 'Microsoft Sans Serif,10,style=Bold'
$SAMNameLabel.Visible        = $True
$AddressForm.Controls.Add($SAMNameLabel)

#TextBox
$SAMName                     = New-Object system.Windows.Forms.TextBox
$SAMName.multiline           = $false
$SAMName.width               = 314
$SAMName.height              = 20
$SAMName.location            = New-Object System.Drawing.Point(150,200)
$SAMName.Font                = 'Microsoft Sans Serif,10'
$SAMName.Visible             = $True
$AddressForm.Controls.Add($SAMName)

#Buttons
$FinduserBtn                   = New-Object system.Windows.Forms.Button
$FinduserBtn.BackColor         = "#a4ba67"
$FinduserBtn.text              = "Find User"
$FinduserBtn.width             = 90
$FinduserBtn.height            = 30
$FinduserBtn.location          = New-Object System.Drawing.Point(150,250)
$FinduserBtn.Font              = 'Microsoft Sans Serif,10'
$FinduserBtn.ForeColor         = "#ffffff"
$AddressForm.CancelButton   = $FinduserBtn
$AddressForm.Controls.Add($FinduserBtn)

$FinduserBtn.Add_Click({ Finduser })

$cancelBtn                       = New-Object system.Windows.Forms.Button
$cancelBtn.BackColor             = "#ffffff"
$cancelBtn.text                  = "Cancel"
$cancelBtn.width                 = 90
$cancelBtn.height                = 30
$cancelBtn.location              = New-Object System.Drawing.Point(260,250)
$cancelBtn.Font                  = 'Microsoft Sans Serif,10'
$cancelBtn.ForeColor             = "#000fff"
$cancelBtn.DialogResult          = [System.Windows.Forms.DialogResult]::Cancel
$AddressForm.CancelButton   = $cancelBtn
$AddressForm.Controls.Add($cancelBtn)

################ Execute #################


function Finduser { 
  Write-host "Finding User" -fore Yellow
  $sam=$SAMName.text
  Write-host $OperationChoice.text

  ### Change the Primary Address ###
if ($OperationChoice.text -eq "Change the Primary Address") {
 $Result = 'Test Option Selected.'
# Init PowerShell Gui
Add-Type -AssemblyName System.Windows.Forms
# Result form
$ResultForm                    = New-Object system.Windows.Forms.Form
$ResultForm.ClientSize         = '500,400'
$ResultForm.text               = "Email Result Management"
$ResultForm.BackColor          = "#bababa"


$ResultText                           = New-Object system.Windows.Forms.Label
$ResultText.text                      = 'You have chosen to edit user:'
$ResultText.AutoSize                  = $true
$ResultText.width                     = 25
$ResultText.height                    = 10
$ResultText.location                  = New-Object System.Drawing.Point(20,10)
$ResultText.Font                      = 'Microsoft Sans Serif,13'
$ResultForm.controls.AddRange(@($ResultText))


# Create a Choice for our form. We will use a label for it.
$ResultChoice                           = New-Object system.Windows.Forms.Label
# The content of the label
$ResultChoice.text                      = $SamName.Text
# Make sure the label is sized the height and length of the content
$ResultChoice.AutoSize                  = $true
# Define the minial width and height (not nessary with autosize true)
$ResultChoice.width                     = 25
$ResultChoice.height                    = 10
# Position the element
$ResultChoice.location                  = New-Object System.Drawing.Point(20,35)
# Define the font type and size
$ResultChoice.Font                      = 'Microsoft Sans Serif,13,style=bold'
$ResultForm.controls.AddRange(@($ResultChoice))




# Create a Title for our form. We will use a label for it.
$EmailTitle                           = New-Object system.Windows.Forms.Label
# The content of the label
$EmailTitle.text                      = 'Current Primary Email Address:'
# Make sure the label is sized the height and length of the content
$EmailTitle.AutoSize                  = $true
# Define the minial width and height (not nessary with autosize true)
$EmailTitle.width                     = 25
$EmailTitle.height                    = 10
# Position the element
$EmailTitle.location                  = New-Object System.Drawing.Point(20,75)
# Define the font type and size
$EmailTitle.Font                      = 'Microsoft Sans Serif,13'
$ResultForm.controls.AddRange(@($EmailTitle))



# Create a Title for our form. We will use a label for it.
$EmailChoice                          = New-Object system.Windows.Forms.Label
# The content of the label
$EmailChoice.text                      = $Email1
# Make sure the label is sized the height and length of the content
$EmailChoice.AutoSize                  = $true
# Define the minial width and height (not nessary with autosize true)
$EmailChoice.width                     = 25
$EmailChoice.height                    = 10
# Position the element
$EmailChoice.location                  = New-Object System.Drawing.Point(20,100)
# Define the font type and size
$EmailChoice.Font                      = 'Microsoft Sans Serif,13,style=Bold'
$ResultForm.controls.AddRange(@($EmailChoice))

#TextBoxLable
$PriEmailLabel                = New-Object system.Windows.Forms.Label
$PriEmailLabel.text           = "Enter New Primary Email:"
$PriEmailLabel.AutoSize       = $true
$PriEmailLabel.width          = 25
$PriEmailLabel.height         = 20
$PriEmailLabel.location       = New-Object System.Drawing.Point(20,200)
$PriEmailLabel.Font           = 'Microsoft Sans Serif,10,style=Bold'
$PriEmailLabel.Visible        = $True
$ResultForm.Controls.Add($PriEmailLabel)

#TextBox
$PriEmail                     = New-Object system.Windows.Forms.TextBox
$PriEmail.multiline           = $false
$PriEmail.width               = 314
$PriEmail.height              = 20
$PriEmail.location            = New-Object System.Drawing.Point(20,230)
$PriEmail.Font                = 'Microsoft Sans Serif,10'
$PriEmail.Visible             = $True
$ResultForm.Controls.Add($PriEmail)

#Result Buttons
$ExecBtn                   = New-Object system.Windows.Forms.Button
$ExecBtn.BackColor         = "#a4ba67"
$ExecBtn.text              = "Process"
$ExecBtn.width             = 90
$ExecBtn.height            = 30
$ExecBtn.location          = New-Object System.Drawing.Point(20,350)
$ExecBtn.Font              = 'Microsoft Sans Serif,10'
$ExecBtn.ForeColor         = "#ffffff"
$ResultForm.CancelButton   = $ExecBtn
$ResultForm.Controls.Add($ExecBtn)

$cancelBtn2                       = New-Object system.Windows.Forms.Button
$cancelBtn2.BackColor             = "#ffffff"
$cancelBtn2.text                  = "Cancel"
$cancelBtn2.width                 = 90
$cancelBtn2.height                = 30
$cancelBtn2.location              = New-Object System.Drawing.Point(170,350)
$cancelBtn2.Font                  = 'Microsoft Sans Serif,10'
$cancelBtn2.ForeColor             = "#000fff"
$cancelBtn2.DialogResult          = [System.Windows.Forms.DialogResult]::Cancel
$ResultForm.CancelButton   = $cancelBtn2
$ResultForm.Controls.Add($cancelBtn2)


# Display the form
$result = $ResultForm.ShowDialog()


$ExecBtn.Add_Click({ Newprim })

$NewPrim = $PriEmail.Text
If (!$newprim) {Write-host "No Address entered." -fore Red}

Else{
Write-host "Setting Primary Address" $newprim -ForegroundColor Green
  ### Test ###

# Process form
$ProcessForm                    = New-Object system.Windows.Forms.Form
$ProcessForm.ClientSize         = '500,400'
$ProcessForm.text               = "Email Process Management"
$ProcessForm.BackColor          = "#abdbff"


# Create a Title for our form. We will use a label for it.
$EmailTitle                           = New-Object system.Windows.Forms.Label
# The content of the label
$EmailTitle.text                      = 'New Primary Email Address for $SamName.Text'
# Make sure the label is sized the height and length of the content
$EmailTitle.AutoSize                  = $true
# Define the minial width and height (not nessary with autosize true)
$EmailTitle.width                     = 25
$EmailTitle.height                    = 10
# Position the element
$EmailTitle.location                  = New-Object System.Drawing.Point(20,75)
# Define the font type and size
$EmailTitle.Font                      = 'Microsoft Sans Serif,13'
$ProcessForm.controls.AddRange(@($EmailTitle))



# Create a Title for our form. We will use a label for it.
$EmailChoice                          = New-Object system.Windows.Forms.Label
# The content of the label
$EmailChoice.text                      = $Email1
# Make sure the label is sized the height and length of the content
$EmailChoice.AutoSize                  = $true
# Define the minial width and height (not nessary with autosize true)
$EmailChoice.width                     = 25
$EmailChoice.height                    = 10
# Position the element
$EmailChoice.location                  = New-Object System.Drawing.Point(20,100)
# Define the font type and size
$EmailChoice.Font                      = 'Microsoft Sans Serif,13,style=Bold'
$ProcessForm.controls.AddRange(@($EmailChoice))



#Buttons
$FinduserBtn                   = New-Object system.Windows.Forms.Button
$FinduserBtn.BackColor         = "#59b8ff"
$FinduserBtn.text              = "OK"
$FinduserBtn.width             = 90
$FinduserBtn.height            = 30
$FinduserBtn.location          = New-Object System.Drawing.Point(20,350)
$FinduserBtn.Font              = 'Microsoft Sans Serif,10'
$FinduserBtn.ForeColor         = "#ffffff"
$ProcessForm.CancelButton   = $FinduserBtn
$ProcessForm.Controls.Add($FinduserBtn)

# Display the form
[void]$ProcessForm.ShowDialog()
Write-host $PriEmail.Text
}
}
#####end sub 1
}
#### End Sub

# ADD OTHER ELEMENTS ABOVE THIS LINE
# Add the elements to the form
$AddressForm.controls.AddRange(@($TitleOperationChoice,$Description,$Status,$PrinterFound))



# Display the form
#[void]$AddressForm.ShowDialog()
$result = $AddressForm.ShowDialog()

