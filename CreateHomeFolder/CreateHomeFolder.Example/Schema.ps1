$obj = New-Object -Type PSCustomObject
$obj | Add-Member -Type NoteProperty -Name "Anchor-objectGuid|String" -Value "00000000-0000-0000-0000-000000000001"
$obj | Add-Member -Type NoteProperty -Name "objectClass|String" -Value "user"
$obj | Add-Member -Type NoteProperty -Name "accountName|String" -Value "kent"
$obj | Add-Member -Type NoteProperty -Name "homeFolderPath|String" -Value "\\server\share\"
$obj