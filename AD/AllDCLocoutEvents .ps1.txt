$DCs =Get-ADDomainController -Filter *

#$DCname = "NESJNBDC02"

Foreach ($DC in $DCs) {
$DCName = $DC.Hostname
$events  = Get-WinEvent -ComputerName $DCName  -FilterHashTable @{ LogName = "Security"; StartTime = "2021-04-12 08:00" ; ID = 4740} | select TimeCreated, ProviderName, Id, @{n='Message';e={$_.Message -replace '\s+', " "}}
$events |Export-Csv C:\Temp\AllDClockoutEvents.csv -Append

}