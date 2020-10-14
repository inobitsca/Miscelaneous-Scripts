
$days = (Get-Date).adddays(-30)
Get-ADUser -SearchBase "OU=Budget Rent-a-Car,DC=mccarthyltd,DC=local"-filter {lastlogondate -le $90days -AND passwordlastset -le $90days} | Disable-ADAccount

Start-Sleep -s 15

Get-Aduser -SearchBase "OU=Budget Rent-a-Car,DC=mccarthyltd,DC=local" -Filter {enabled -eq $False} | Move-ADObject -TargetPath "ou=Disabled Users,dc=Neotel,dc=co,dc=za"