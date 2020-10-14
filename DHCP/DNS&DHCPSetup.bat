dnscmd  /zoneadd _msdcs.domdyn.net /secondary 172.16.128.174 172.16.128.178
dnscmd  /zoneadd domdyn.net /secondary 172.16.128.174 172.16.128.178
dnscmd  /zoneadd 16.172.in-addr.arpa /secondary 172.16.128.174 172.16.128.178
dnscmd  /zoneadd 17.172.in-addr.arpa /secondary 172.16.128.174 172.16.128.178
dnscmd  /zoneadd 18.172.in-addr.arpa /secondary 172.16.128.174 172.16.128.178
dnscmd  /zoneadd 19.172.in-addr.arpa /secondary 172.16.128.174 172.16.128.178
dnscmd  /zoneadd 20.172.in-addr.arpa /secondary 172.16.128.174 172.16.128.178
dnscmd  /zoneadd 21.172.in-addr.arpa /secondary 172.16.128.174 172.16.128.178

dnscmd /resetforwarders 172.16.128.174 172.16.128.178




netsh dhcp server add server ermvorto.domdyn.net 172.16.14.14
netsh dhcp server add scope 172.16.14.0 255.255.255.0 EastRandMall
netsh dhcp server Set Scope 172.16.14.0 add iprange 172.16.14.100 172.16.14.250
netsh dhcp server set optionvalue 3 IPADDRESS 172.16.14.14
netsh dhcp server set optionvalue 6 IPADDRESS 172.16.14.14 172.16.128.174 172.16.128.178
