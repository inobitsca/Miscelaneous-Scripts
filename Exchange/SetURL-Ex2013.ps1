#Exchange 2013 Set Url Script
# Description: This script sets internal and external URL’s on the specified Exchange 2013 Client Access Server
# then displays the results of all the urls that have been set.
# How to Use: Copy the text file to a location on the Exchange server. Change the .txt extension to .ps1,
# Open Exchange Management Shell, Browse to the location of the script in EMS, Run .\Set-Exchange2013Vdirs#

Function Set-Exchange2013Vdirs
{
$ExServer = Read-Host “Please enter the Exchange 2013 Server Name you’d like to set Vdirs ”
$InternalName = Read-Host “Input the internal domain name eg.. IntMail.domain.com ”
$ExternalName = Read-Host “Input the external domain name eg. ExtMail.domain.com ”

Write-Host “Configuring Directories for $ExServer..” -Foregroundcolor Green

Get-WebservicesVirtualDirectory -Server $ExServer | Set-WebservicesVirtualDirectory -InternalURL https://$InternalName/EWS/Exchange.asmx -ExternalURL https://$externalName/EWS/Exchange.asmx
Get-OwaVirtualDirectory -Server $ExServer | Set-OwaVirtualDirectory -InternalURL https://$InternalName/owa -ExternalURL https://$ExternalName/owa
Get-ecpVirtualDirectory -Server $ExServer | Set-ecpVirtualDirectory -InternalURL https://$InternalName/ecp -ExternalURL https://$ExternalName/ecp
Get-ActiveSyncVirtualDirectory -Server $ExServer | Set-ActiveSyncVirtualDirectory -InternalURL https://$InternalName/Microsoft-Server-ActiveSync -ExternalURL https://$ExternalName/Microsoft-Server-ActiveSync
Get-OABVirtualDirectory -Server $ExServer | Set-OABVirtualDirectory -InternalUrl https://$InternalName/OAB -ExternalURL https://$ExternalName/OAB
Set-ClientAccessServer $ExServer -AutodiscoverServiceInternalUri https://$internalName/Autodiscover/Autodiscover.xml
Set-OutlookAnywhere -Identity “$ExServer\Rpc (Default Web Site)” -InternalHostname $internalName -ExternalHostName $ExternalName -InternalClientAuthenticationMethod ntlm -InternalClientsRequireSsl:$True -ExternalClientAuthenticationMethod NTLM -ExternalClientsRequireSsl:$True

Write-Host “Vdirs have been set to the following..” -Foregroundcolor Green
Write-Host “$ExServer EWS”
Get-WebservicesVirtualDirectory -Server $ExServer |Fl internalURL,ExternalURL
Write-Host “$ExServer OWA”
Get-OWAVirtualDirectory -Server $ExServer | Fl internalUrl,ExternalURL
Write-Host “$ExServer ECP”
Get-ECPVirtualDirectory -Server $ExServer | Fl InternalURL,ExternalURL
Write-Host “$ExServer ActiveSync”
Get-ActiveSyncVirtualDirectory -Server $ExServer | Fl InternalURL,ExternalURL
Write-Host “$ExServer OAB”
Get-OABVirtualDirectory -Server $ExServer | Fl InternalURL,ExternalURL
Write-Host “$ExServer Internal Autodiscover URL”
Get-ClientAccessServer $ExServer | Fl AutodiscoverServiceInternalUri
Write-Host “$Exserver Outlook Anywhere Settings”
Get-OutlookAnywhere -Identity “$ExServer\rpc (Default Web Site)” |fl internalhostname,internalclientauthenticationmethod,internalclientsrequiressl,externalhostname,externalclientauthenticationmethod,externalclientsrequiressl

Write-Host “The Powershell URL have not been set as part of this script. Set it if you choose” -ForegroundColor Yellow
}
Set-Exchange2013Vdirs

