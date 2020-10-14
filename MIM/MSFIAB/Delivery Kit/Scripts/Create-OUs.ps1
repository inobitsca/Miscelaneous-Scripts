# FIM-in-a-Box Installation and configuration scripts
# Copyright 2010-2011, Microsoft Corporation
#
# December 2010 | Soren Granfeldt
#	- initial script

.\Initialize-FIMScript.ps1

$objDomain = [ADSI]"LDAP://$DefaultNamingContext"

$objOU = $objDomain.Create("OrganizationalUnit", "ou=" + $ManagedOU)
$objOU.SetInfo()

$objOU = $objDomain.Create("OrganizationalUnit", "ou=" + $ServiceAccountsOU)
$objOU.SetInfo()

.\Terminate-FIMScript.ps1
