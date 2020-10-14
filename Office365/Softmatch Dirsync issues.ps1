
Import-module MSonline
Import-module ActiveDirectory

Write-host "You will now be asked to enter your Office 365 Credentials:" -fore Green
Write-host "e.g. admin@TENANT.onmicrosoft.com"  -fore Green
Write-host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
$cred = Get-Credential
$cred

Connect-MsolService -Credential $cred

$ADUPN = Read-Host "Enter the AD User Principal Name"
$MSOLUPN = Read-Host "Enter the MSOnline User Principal Name"
$guid = (get-aduser -filter 'userprincipalname -eq $ADUPN').ObjectGuid
$immutableID = [System.Convert]::ToBase64String($guid.tobytearray())
$OldIMID= (get-msoluser -UserPrincipalName $MSOLUPN).ImmutableId
If ($OldIMID -ne $immutableID ){
Write-Host "There is a mismatch. Updating Office365 account: " $MSOLUPN -fore Yellow
Set-MSOLuser -UserPrincipalName $MSOLUPN -ImmutableID $immutableID 
Sleep -s 3
$OldIMID = (get-msoluser -UserPrincipalName $MSOLUPN).ImmutableId
If ($OldIMID -eq $immutableID ){
Write-Host "There is no longer a mismatch." -fore green
}
else {Write-host "Something went wrong." -fore red
}
}
else { Write-Host "There is no mismatch. Nothing to update" -fore Cyan }