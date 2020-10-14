#####################################################################
# makecert.ps1
# Version 1.0
#
# Creates self-signed signing certificate and install it to certificate store
#
# Note: Requires at least Windows Vista. Windows XP/Windows Server 2003
# are not supported.
#
# Pavel Khodak, 2012 
# http://blogs.msdn.com/b/pavelkhodak/
# Based on the work of 
# Vadims Podans - http://www.sysadmins.lv/
# Adam Conkle - http://social.technet.microsoft.com/wiki/contents/articles/4714.how-to-generate-a-self-signed-certificate-using-powershell-en-us.aspx
#####################################################################

Write-Host "`n WARNING: This script sample is provided AS-IS with no warranties and confers no rights." -ForegroundColor Yellow 
Write-Host "`n This script sample will generate self-signed certificates with private key" 
Write-Host " in the Local Computer Personal certificate store." 

$Subject = [string]::Format('{0}.{1}', $env:computername, $env:userdnsdomain)
$CustomSubject = Read-Host "`n Would you like to change subject from $Subject Y/[N]"
if ($CustomSubject -eq "Y") 
{
	$Subject = Read-Host "`n Enter the Subject for certificate"  
}

$NotBefore = [DateTime]::UtcNow
# Make certificate valid for 10 years
$NotAfter = $NotBefore.AddDays(365 * 10)

$Force = $true
$InstallAsRoot = Read-Host "`n Would you like to install this certificate to Trusted Root Certification Authorities? [Y]/N"
if ($InstallAsRoot -eq "N") 
{
	$Force = $false 
}

$OS = (Get-WmiObject Win32_OperatingSystem).Version
if ($OS[0] -lt 6) 
{
	Write-Warning "Windows XP, Windows Server 2003 and Windows Server 2003 R2 are not supported!"
}
else
{
	# while all certificate fields MUST be encoded in ASN.1 DER format
	# we will use CryptoAPI COM interfaces to generate and encode all necessary
	# extensions.
	
	# create Subject field in X.500 format using the following interface:
	# http://msdn.microsoft.com/en-us/library/aa377051(VS.85).aspx
	$SubjectDN = New-Object -ComObject X509Enrollment.CX500DistinguishedName
	$SubjectDN.Encode("CN=$Subject", 0x0)
	
	# Add certificate key usage statements.
	$OIDs = New-Object -ComObject X509Enrollment.CObjectIDs
	
	# define Server authentication enhanced key usage (actual OID = 1.3.6.1.5.5.7.3.1)
	$OID = New-Object -ComObject X509Enrollment.CObjectID
	$OID.InitializeFromValue("1.3.6.1.5.5.7.3.1")
	$OIDs.Add($OID)

	# define Client authentication enhanced key usage (actual OID = 1.3.6.1.5.5.7.3.2) 
	$OID = New-Object -ComObject X509Enrollment.CObjectID
	$OID.InitializeFromValue("1.3.6.1.5.5.7.3.2")
	$OIDs.Add($OID)
	
	# define SmartCard authentication enhanced key usage (actual OID = 1.3.6.1.4.1.311.20.2.2) 
	$OID = New-Object -ComObject X509Enrollment.CObjectID
	$OID.InitializeFromValue("1.3.6.1.4.1.311.20.2.2")
	$OIDs.Add($OID)

	# define CodeSigning enhanced key usage (actual OID = 1.3.6.1.5.5.7.3.3) from OID
	$OID = New-Object -ComObject X509Enrollment.CObjectID
	$OID.InitializeFromValue("1.3.6.1.5.5.7.3.3")
	$OIDs.Add($OID)
	
	# now we create Enhanced Key Usage extension, add our OIDs and encode extension value
	# http://msdn.microsoft.com/en-us/library/aa378132(VS.85).aspx
	$EKU = New-Object -ComObject X509Enrollment.CX509ExtensionEnhancedKeyUsage
	$EKU.InitializeEncode($OIDs)
	
	# generate Private key as follows:
	# http://msdn.microsoft.com/en-us/library/aa378921(VS.85).aspx
	$PrivateKey = New-Object -ComObject X509Enrollment.CX509PrivateKey
	$PrivateKey.ProviderName = "Microsoft RSA SChannel Cryptographic Provider"
	$PrivateKey.KeySpec = 0x1
	$PrivateKey.Length = 2048
	# set security descriptor
	$PrivateKey.SecurityDescriptor = "D:PAI(A;;0xd01f01ff;;;SY)(A;;0xd01f01ff;;;BA)(A;;0x80120089;;;NS)"
	# key will be stored in local machine certificate store
	$PrivateKey.MachineContext = 0x1
	# export will be allowed
	$PrivateKey.ExportPolicy = 0x1
	$PrivateKey.Create()
	
	# now we need to create certificate request template using the following interface:
	# http://msdn.microsoft.com/en-us/library/aa377124(VS.85).aspx
	$Cert = New-Object -ComObject X509Enrollment.CX509CertificateRequestCertificate
	$Cert.InitializeFromPrivateKey(0x2,$PrivateKey,"")
	$Cert.Subject = $SubjectDN
	$Cert.Issuer = $Cert.Subject
	$Cert.NotBefore = $NotBefore
	$Cert.NotAfter = $NotAfter
	$Cert.X509Extensions.Add($EKU)
	# completing certificate request template building
	$Cert.Encode()
	
	# now we need to process request and build end certificate using the following
	# interface: http://msdn.microsoft.com/en-us/library/aa377809(VS.85).aspx
	
	$Request = New-Object -ComObject X509Enrollment.CX509enrollment
	# process request
	$Request.InitializeFromRequest($Cert)
	# retrievecertificate encoded in Base64.
	$endCert = $Request.CreateRequest(0x1)
	# install certificate to user store
	$Request.InstallResponse(0x2,$endCert,0x1,"")
	
	if ($Force) 
	{
		# convert Bas64 string to a byte array
	 	[Byte[]]$bytes = [System.Convert]::FromBase64String($endCert)
		foreach ($Container in "Root", "TrustedPublisher") 
		{
			# open Trusted Root CAs and TrustedPublishers containers and add
			# certificate
			$x509store = New-Object Security.Cryptography.X509Certificates.X509Store $Container, "LocalMachine"
			$x509store.Open([Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
			$x509store.Add([Security.Cryptography.X509Certificates.X509Certificate2]$bytes)
			# close store when operation is completed
			$x509store.Close()
		}
	}		
}
Write-Host "`n Completed`n" -ForegroundColor Green