# FIM-in-a-Box Installation and configuration scripts
# Copyright 2010-2011, Microsoft Corporation
#
# December 2010 | Soren Granfeldt
#	- initial script

.\Initialize-FIMScript.ps1

function CreateUser($AccountName, $WhichOU, $Description)
{
	$UserOU = [ADSI] "LDAP://OU=$WhichOU,$DefaultNamingContext"

	$User = $UserOU.create("user","cn=$AccountName")
	$User.put("sAMAccountName", "$AccountName")
	$User.put("description", "$Description")
	$User.SetInfo()

	$User.put("useraccountcontrol", $User.useraccountcontrol.value -band (-bnot 2)) 
	$user.SetInfo() 

	$User.SetPassword("Passw0rd")
	$User.SetInfo()
}

function CreateGroup($AccountName, $WhichOU)
{
	$GroupOU = [ADSI] "LDAP://OU=$WhichOU,$DefaultNamingContext"

	$Group = $GroupOU.Create("group", "CN=" + $AccountName)
	$Group.Put("sAMAccountName", $AccountName )
	$Group.SetInfo()
}

CreateUser -AccountName SVC-FIM-SPAppPool -WhichOU "$ServiceAccountsOU" -Description "SharePoint Application Pool Service Account" 
CreateUser -AccountName SVC-FIM-Service -WhichOU "$ServiceAccountsOU" -Description "Forefront Identity Manager 2010 Service Account" 
CreateUser -AccountName SVC-FIM-MA -WhichOU "$ServiceAccountsOU" -Description "Forefront Identity Manager 2010 Management Agent Service Account" 
CreateUser -AccountName SVC-FIM-Sync -WhichOU "$ServiceAccountsOU" -Description "Forefront Identity Manager 2010 Synchronization Service Service Account" 
CreateUser -AccountName SVC-FIM-ADMA -WhichOU "$ServiceAccountsOU" -Description "Active Directory Management Agent Service Account" 

CreateGroup -AccountName FIMSyncAdmins -WhichOU "$ServiceAccountsOU" 
CreateGroup -AccountName FIMSyncBrowse -WhichOU "$ServiceAccountsOU" 
CreateGroup -AccountName FIMSyncJoiners -WhichOU "$ServiceAccountsOU" 
CreateGroup -AccountName FIMSyncOperators -WhichOU "$ServiceAccountsOU" 
CreateGroup -AccountName FIMSyncPasswordSet -WhichOU "$ServiceAccountsOU" 

# Put SVC-FIM-Service ==> FIMSyncAdmins or FIMSyncPasswordSet
NET GROUP FIMSyncAdmins      SVC-FIM-Service /ADD /DOMAIN
NET GROUP FIMSyncPasswordSet SVC-FIM-Service /ADD /DOMAIN

.\Terminate-FIMScript.ps1
