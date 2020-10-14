# Init PowerShell Gui
Add-Type -AssemblyName System.Windows.Forms
# Create a new form
$ResultForm                    = New-Object system.Windows.Forms.Form
# Define the size, title and background color
$ResultForm.ClientSize         = '400,100'
$ResultForm.text               = "Email Result Management"
$ResultForm.BackColor          = "#ffffff"

# Create a Title for our form. We will use a label for it.
$ResultTitle                           = New-Object system.Windows.Forms.Label
# The content of the label
$ResultTitle.text                      = "Title block"
# Make sure the label is sized the height and length of the content
$ResultTitle.AutoSize                  = $true
# Define the minial width and height (not nessary with autosize true)
$ResultTitle.width                     = 25
$ResultTitle.height                    = 10
# Position the element
$ResultTitle.location                  = New-Object System.Drawing.Point(20,20)
# Define the font type and size
$ResultTitle.Font                      = 'Microsoft Sans Serif,13'
$ResultForm.controls.AddRange(@($ResultTitle))

# Display the form
[void]$ResultForm.ShowDialog()