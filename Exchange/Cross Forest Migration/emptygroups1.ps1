$groups = Get-ADGroup  -searchbase "OU=ALTRISK USERS,OU=Altrisk,OU=Arcadia,OU=Users Groups,DC=hicnet,DC=loc" -Filter *

foreach ($Group in $Groups)
{

$GroupName = $group.SAMAccountName

$counter = get-adgroup $groupname |Get-ADGroupMember | Measure-Object 

foreach ($Count in $Counter)
{
$count = $counter.count
 
}

Write-host $Groupname $Count

}

