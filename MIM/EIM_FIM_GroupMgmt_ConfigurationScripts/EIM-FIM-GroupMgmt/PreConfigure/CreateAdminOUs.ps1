$domainName = "dc=contoso,dc=com";
$topAdminOUName = "ou=Administration";
$adminServiceAcctOU = "ou=Service Accounts";
$adminGroupOU = "ou=Administrative Groups";
$adminAppAcctOU = "ou=Application Accounts";

$domConnect = [ADSI] "LDAP://$domainName";

$newTopOU = $domConnect.Create("OrganizationalUnit", $topAdminOUName);
$newTopOU.SetInfo();

Set-ADOrganizationalUnit "$topAdminOUName,$domainName" -ProtectedFromAccidentalDeletion $True;

$adminTopOUPath = [ADSI]($newTopOU.path)
$newSvcAcctSubOU = $adminTopOUPath.Create("OrganizationalUnit", $adminServiceAcctOU);
$newSvcAcctSubOU.SetInfo();

Set-ADOrganizationalUnit "$adminServiceAcctOU,$topAdminOUName,$domainName" -ProtectedFromAccidentalDeletion $True;

$newAdminGroupOU = $adminTopOUPath.Create("OrganizationalUnit", $adminGroupOU);
$newAdminGroupOU.SetInfo();

Set-ADOrganizationalUnit "$adminGroupOU,$topAdminOUName,$domainName" -ProtectedFromAccidentalDeletion $True;

$newAppAcctSubOU = $adminTopOUPath.Create("OrganizationalUnit", $adminAppAcctOU);
$newAppAcctSubOU.SetInfo();

Set-ADOrganizationalUnit "$adminAppAcctOU,$topAdminOUName,$domainName" -ProtectedFromAccidentalDeletion $True;