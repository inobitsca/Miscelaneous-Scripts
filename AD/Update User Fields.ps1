Import-CSV import.csv | % {Get-ADuser $_.SamAccountName | Set-ADuser -replace @{EmployeeID=$_.EmployeeID}}
