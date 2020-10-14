import-module activedirectory
$oldSuffix = "itecgroup.local"
$newSuffix = "itecgroup.co.za"
$Users=  Get-ADUser -SearchBase "OU=ITEC 3D,DC=itecgroup,DC=local" -SearchScope OneLevel -filter * 

ForEach ($User in $Users)  {
$UPN = $User.UserPrincipalName
$U=$User.SamAccountName
$newUpn = $UPN.Replace($oldSuffix,$newSuffix)
Set-ADUser $U -server ITECHVDC2.itecgroup.local -UserPrincipalName $newUpn
Write-host "Old UPN is "$UPN ", Username is " $U ", New UPN is " $NewUPN 
}
