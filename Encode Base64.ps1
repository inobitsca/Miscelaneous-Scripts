$Text = "cedrica@jse.co.za"
$Bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
$EncodedText =[Convert]::ToBase64String($Bytes)
$EncodedText

$Text2 = "MyPassword"
$Bytes = [System.Text.Encoding]::UTF8.GetBytes($Text2)
$EncodedText2 =[Convert]::ToBase64String($Bytes)
$EncodedText2


$b  = [System.Convert]::FromBase64String($EncodedText)
[System.Text.Encoding]::UTF8.GetString($b)

$path = "C:\Users\cedri\Pictures\External Email Banner2.jpg"
$Encoded = [Convert]::ToBase64String((Get-Content -Path $path -Encoding Byte))
$Encoded > c:\temp\encoded.txt