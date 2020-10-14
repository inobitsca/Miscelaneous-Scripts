#Install portal with PAM
#Install the PAM Addins
   
   Import-Module MIMPAM
   Import-Module ActiveDirectory

$Sa = "MIMAdmin"
    $sj = New-PAMUser –SourceDomain inobitsza.com –SourceAccountName $Sa
    $jp = ConvertTo-SecureString "Pass@word" –asplaintext –force
    Set-ADAccountPassword –identity $sa –NewPassword $jp
    Set-ADUser –identity $sa –Enabled 1

    
  
	  
     ## $Cred = get-credential –UserName inobitsza\cedricadmin –Message " forest domain admin credentials"
     $pg = New-PAMGroup –SourceGroupName "PAMAdminGroup" –SourceDomain inobitsza.com  –SourceDC inazdc02.inobitsza.com –PrivOnly ## –Credentials $Cred 
     $pr = New-PAMRole –DisplayName "PAMTestAdminGroup" –Privileges $pg –Candidates $sa

     $sj = get-pamuser -SourceAccountName MIMuser1
      $pg = get-PAMGroup –SourceAccountName "TestAdminGroup"


     Remove-ADGroupMember -identity "TestAdminGroup" -Members "MIMUser1"

     $Pr = get-pamrole PAMTestAdminGroup
     Set-PAMRole -Role $pr -ApprovalEnabled $true -Approvers $sj
     

     iisreset /STOP 
     C:\Windows\System32\inetsrv\appcmd.exe unlock config /section:windowsAuthentication -commit:apphost 
     iisreset /START

     notepad.exe C:\Windows\System32\inetsrv\config\applicationHost.config

<#   Scroll down to line 82 of that file. The tag value of overrideModeDefault should be
Change the value of overrideModeDefault to Allow
Save the file, and restart IIS with the PowerShell command iisreset /START #>

IISReset
 MD "C:\Program Files\Microsoft Forefront Identity Manager\2010\PAMPortal"

New-WebSite -Name "MIM PAM Portal" -Port 8090   -PhysicalPath "C:\Program Files\Microsoft Forefront Identity Manager\2010\PAMPortal\"


notepad "C:\Program Files\Microsoft Forefront Identity Manager\2010\Privileged Access Management REST API\web.config"
<#
https://docs.microsoft.com/en-us/microsoft-identity-manager/pam/step-4-install-mim-components-on-pam-server
######
 In the <system.webServer> section, add the following lines:

<httpProtocol>
<customHeaders>
  <add name="Access-Control-Allow-Credentials" value="true"  />
  <add name="Access-Control-Allow-Headers" value="content-type" />
  <add name="Access-Control-Allow-Origin" value="http://mim.inobitsza.com:8090" />  
</customHeaders>
</httpProtocol>



Replace   <authentication> section with:

      <authentication>
        <windowsAuthentication enabled="false" useKernelMode="false">
                    <extendedProtection tokenChecking="None" />
                    <providers>
                        <clear />
                        <add value="Negotiate" />
                        <add value="NTLM" />
                    </providers>
                </windowsAuthentication>
      </authentication>
 #>


<# 
https://github.com/myFIMGithub/SelfServiceGroupPrivilegedAccess-MIM2016
https://github.com/Azure/identity-management-samples
#>

notepad "C:\Program Files\Microsoft Forefront Identity Manager\2010\PAMPortal\js\utils.js." # Change the target pamRespApiUrl to http://mim.inobitsza.com:8086/api/pamresources/


$pamrole = Get-PAMRole -DisplayName "PamAdminsGroup"
$pamuser = Get-PAMUser -SourceAccountName "MIMadmin"
Set-PAMRole -Role $pamrole -ApprovalEnabled $true -Approvers $pamuser


<# Ensure tha MIM Admin Account and PAM Service account have rights in AD #>
dsacls "cn=adminsdholder,cn=system,dc=premierfoods,dc=com" /G premierfoods\SVCmimservice:WP;"member"
dsacls "cn=adminsdholder,cn=system,dc=premierfoods,dc=com" /G premierfoods\SVCMIMPAM:WP;"member"