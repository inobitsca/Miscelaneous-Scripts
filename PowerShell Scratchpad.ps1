#TextBoxLable
$PriEmailLabel                = New-Object system.Windows.Forms.Label
$PriEmailLabel.text           = "samAccountName:"
$PriEmailLabel.AutoSize       = $true
$PriEmailLabel.width          = 25
$PriEmailLabel.height         = 20
$PriEmailLabel.location       = New-Object System.Drawing.Point(20,200)
$PriEmailLabel.Font           = 'Microsoft Sans Serif,10,style=Bold'
$PriEmailLabel.Visible        = $True
$AddressForm.Controls.Add($PriEmailLabel)

#TextBox
$PriEmail                     = New-Object system.Windows.Forms.TextBox
$PriEmail.multiline           = $false
$PriEmail.width               = 314
$PriEmail.height              = 20
$PriEmail.location            = New-Object System.Drawing.Point(150,200)
$PriEmail.Font                = 'Microsoft Sans Serif,10'
$PriEmail.Visible             = $True
$AddressForm.Controls.Add($PriEmail)

Alldigital2020