Import-Module ActiveDirectory
$CurrentDate = Get-Date
$CurrentDate = $CurrentDate.ToString('dd-MMMM_yyyy_hh-mm')
Get-aduser -Filter * -Searchbase "OU=McCarthy Motor Holdings,DC=mccarthyltd,DC=local" -Properties * | Select GivenName, Surname, SamAccountName, Description, Pager, wWWHomePage, title, department, company, whenCreated, lastlogon, lastLogontimestamp, lastLogonDate, userAccountControl, mail, homeMDB, DistinguishedName | Export-CSV \\mmhjhbisofs001\adexports\McCarthy-Users-$Currentdate.csv