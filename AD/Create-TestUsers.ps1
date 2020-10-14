Import-Module ActiveDirectory

$RootDse = [ADSI] "LDAP://RootDSE"
$ForestDn = $RootDse.defaultNamingContext
$pass =  read-host "Enter the password for the service account"
$sp = ConvertTo-SecureString $pass –asplaintext –force
$UPNS = Get-Item Env:\USERDNSDOMAIN


New-ADOrganizationalUnit -Name "Testing" -Path "$ForestDn" -ErrorAction SilentlyContinue
New-AdOrganizationalUnit -Name Users  -Path "OU=Testing,$ForestDn" -ErrorAction SilentlyContinue
New-AdOrganizationalUnit -Name Groups -Path "OU=Testing,$ForestDn" -ErrorAction SilentlyContinue

Import-Csv Create-TestUsers.csv | foreach `
{
$UPN = $_.username + "@" + $UPNS.value
New-ADUser $_.Username -Path "OU=Users,OU=Testing,$ForestDn" -OtherAttributes @{givenName="$($_.FirstName)";sn="$($_.LastName)";displayName="$($_.FirstName) $($_.LastName)";title="$($_.Title)"} -ErrorAction SilentlyContinue
Set-ADAccountPassword –identity $_.Username –NewPassword $sp
Set-ADUser –identity $_.Username –Enabled 1 
Set-ADUser –identity $_.Username -UserPrincipalName $UPN

}