clear-host

Import-Module ActiveDirectory

$RootDse = [ADSI] "LDAP://RootDSE"
$ForestDn = $RootDse.defaultNamingContext

New-ADOrganizationalUnit -Name Fabrikam -Path "$ForestDn" -ErrorAction SilentlyContinue
New-AdOrganizationalUnit -Name Users  -Path "OU=Fabrikam,$ForestDn" -ErrorAction SilentlyContinue
New-AdOrganizationalUnit -Name Groups -Path "OU=Fabrikam,$ForestDn" -ErrorAction SilentlyContinue

Import-Csv TestUsers.csv | foreach `
{
	New-ADUser $_.Username -Path "OU=Users,OU=Fabrikam,$ForestDn" -OtherAttributes @{givenName="$($_.FirstName)";sn="$($_.LastName)";displayName="$($_.FirstName) $($_.LastName)";title="$($_.Title)"} -ErrorAction SilentlyContinue
}

# Restart Server
Restart-Computer