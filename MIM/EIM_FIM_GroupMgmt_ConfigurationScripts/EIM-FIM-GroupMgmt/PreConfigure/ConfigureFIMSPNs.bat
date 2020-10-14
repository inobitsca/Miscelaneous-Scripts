rem Setting FIMService SPN's
rem FIMService
setspn -S FIMService/idweb FABRIKAM\SVC-FIM
timeout 3
setspn -S FIMService/idweb.fabrikam.com FABRIKAM\SVC-FIM
timeout 3
setspn -S FIMService/FIMSRV01 FABRIKAM\SVC-FIM
timeout 3
setspn -S FIMService/FIMSRV01.fabrikam.com FABRIKAM\SVC-FIM
timeout 3
rem HTTP and HTTPS
setspn -s HTTP/idweb FABRIKAM\SVC-FIM-WSS
timeout 3
setspn -s HTTPS/idweb FABRIKAM\SVC-FIM-WSS
timeout 3
setspn -s HTTP/idweb.fabrikam.com FABRIKAM\SVC-FIM-WSS
timeout 3
setspn -s HTTPS/idweb.fabrikam.com FABRIKAM\SVC-FIM-WSS
timeout 3
setspn -s HTTP/FIMSRV01 FABRIKAM\SVC-FIM-WSS
timeout 3
setspn -s HTTPS/FIMSRV01 FABRIKAM\SVC-FIM-WSS
timeout 3
setspn -s HTTP/FIMSRV01.fabrikam.com FABRIKAM\SVC-FIM-WSS
timeout 3
setspn -s HTTPS/FIMSRV01.fabrikam.com FABRIKAM\SVC-FIM-WSS
rem ** SPN Configuration Complete **