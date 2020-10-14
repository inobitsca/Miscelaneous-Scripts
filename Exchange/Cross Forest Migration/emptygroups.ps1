Get-ADGroup  -searchbase "OU=ALTRISK USERS,OU=Altrisk,OU=Arcadia,OU=Users Groups,DC=hicnet,DC=loc" -Filter * |

foreach {

 New-Object -TypeName psobject -Property @{

 GroupName = $_.Name

 MemberCount = Get-ADGroupMember -Identity "$($_.samAccountName)" | Measure-Object | select -ExpandProperty Count

}

} | sort MemberCount 