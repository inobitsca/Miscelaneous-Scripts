# FIM-in-a-Box Installation and configuration scripts
# Copyright 2010-2011, Microsoft Corporation
#
# March 2011 | Søren Granfeldt
#   - Added replace statement for <last-dc>

.\Initialize-FIMScript.ps1

DIR MAs\*.XML | % `
{
	$MA = Get-Content "MAs\$($_.Name)"
	$MA = $MA -replace "DC=test,DC=intern", "$($RootDse.defaultNamingContext)"
	$MA = $MA -replace ">test.intern<", ">$FQDN<"
	$MA = $MA -replace ">FIM01<", ">$Hostname<"
	$MA = $MA -replace "ForestDnsZones.test.intern", "ForestDnsZones.$FQDN"
	$MA = $MA -replace "DomainDnsZones.test.intern", "DomainDnsZones.$FQDN"
	$MA = $MA -replace ">test<", ">$DomainNetBIOSName<"
	$MA = $MA -replace "<last-dc>AD01.test.intern</last-dc>", "<last-dc>AD01.test.intern</last-dc>"
	$MA | Set-Content "CustomerFiles\$($_.Name)"
}

.\Terminate-FIMScript.ps1
