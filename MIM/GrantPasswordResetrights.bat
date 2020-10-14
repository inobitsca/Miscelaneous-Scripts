@echo off 

set targetDN=DC=netsurit,DC=com 
set trustee=Netsurit\MIMSyncPasswordReset 

echo "Reset Password" Control Access Right (CAS) 
dsacls "%targetDN%" /I:S /G "%trustee%":CA;"Reset Password";user 1>NUL 

echo Write Property lockoutTime on descendant user objects 
dsacls "%targetDN%" /I:S /G "%trustee%":WP;lockoutTime;user 1>NUL 

echo Write Property userAccountControl on descendant user objects 
dsacls "%targetDN%" /I:S /G "%trustee%":WP;userAccountControl;user 1>NUL 

set targetDN= 
set trustee= 

echo All done. 