$groups = Get-MsolGroup -MaxResults 5000 -GroupType security
$C=$groups|measure
$Total = $C.count
 $count = 1
foreach ($group in $Groups) {
Write-host "Extracting Group $count of $Total"
$GN = $group.DisplayName
$ID = $Group.ObjectId
Get-MsolGroupMember -GroupObjectId $ID -MaxResults 5000 |Select GroupMemberType,EmailAddress, DisplayName,@{n="GroupName";e={"$GN"}} |export-csv .\PremierAADGroups.csv -append
$count=$count + 1
}


