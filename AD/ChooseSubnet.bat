ipconfig | find /i "172.16.200."
IF NOT errorlevel 1 start http://172.16.200.14/lab.htm
ipconfig | find /i "10.255.1."
IF NOT errorlevel 1 start http://172.16.200.14/wireless.htm
ipconfig | find /i "110.255.2."
IF NOT errorlevel 1 start http://172.16.200.14/clients.htm