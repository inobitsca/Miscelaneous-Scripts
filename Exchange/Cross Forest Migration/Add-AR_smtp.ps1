Import-Module ActiveDirectory

$proxydomain = "@altrisk.co.za"
$Groups = Get-ADGroup  -Properties * -filter {name -like "#AR_*"}

Foreach ($group in $groups) {
$ID = $Group.Samaccountname
Write-host $Group.Samaccountname

Get-ADGroup $ID | Set-ADGroup -Add @{Proxyaddresses="smtp:"+$ID+$proxydomain} 

    } 