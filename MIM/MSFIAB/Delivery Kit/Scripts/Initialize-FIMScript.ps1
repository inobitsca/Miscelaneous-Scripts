# FIM-in-a-Box Installation and configuration scripts
# Copyright 2010-2011, Microsoft Corporation
#
# December 2010 | Soren Granfeldt
#	- initial script
# March 2011 | Søren Granfeldt
#   - Added call to ServerManagerCmd to install Active Directory Administration Tools

ServerManagerCmd -Install RSAT-ADDS

Import-Module ActiveDirectory 

$global:RootDse = [ADSI] "LDAP://RootDSE"
$global:DefaultNamingContext = $RootDse.defaultNamingContext
$global:Domain = [ADSI] "LDAP://$DefaultNamingContext"
$global:DomainNetBIOSName = $Domain.Name.ToString().ToUpper()
$global:FQDN = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
$global:Username = (whoami).ToUpper()
$global:Hostname = (hostname).ToUpper()

$global:ManagedOU = "FIM Managed Users and Groups"
$global:ServiceAccountsOU = "FIM Service Accounts"

Write-Host "`n`rFIM-in-a-Box Configuration Script`n`r"

Write-Host "Default Naming Context: '$($RootDse.defaultNamingContext)'"
Write-Host "NetBIOS domain name: '$DomainNetBIOSName'"
Write-Host "FQDN domain is: '$FQDN'"
Write-Host "Username is: '$Username'"
