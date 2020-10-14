$Protected = Get-ADUser  -SearchBase "OU=temp,DC=silica,DC=net" -Filter * -Properties nTSecurityDescriptor | ?{ $_.nTSecurityDescriptor.AreAccessRulesProtected -eq "True" }
