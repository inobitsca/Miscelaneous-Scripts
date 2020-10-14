function global:GET-CName { 
param([string]$DN) 
 
# Split the Distinguished name into separate bits 
# 
$Parts=$DN.Split(",") 
 
# Figure out how deep the Rabbit Hold goes 
# 
$NumParts=$Parts.Count 
 
# Although typically 2 DC entries, make sure and figure out the length of the FQDN 
# 
$FQDNPieces=($Parts -match 'DC').Count 
 
# Keep track of where the FQDN is (calling it the middle even if it 
# Could be WAY out there somewhere 
# 
$Middle=$NumParts-$FQDNPieces 
 
# Build the CN.  First part is separated by '.' 
#  
foreach ($x in ($Middle+1)..($NumParts)) { 
    $CN+=$Parts[$x-1].SubString(3)+'.' 
    } 
 
# Get rid of that extra Dot 
# 
$CN=$CN.substring(0,($CN.length)-1) 
 
# Now go BACKWARDS and build the rest of the CN 
# 
foreach ($x in ($Middle-1)..0) {  
    $Parts[$x].substring(3) 
    $CN+="/"+$Parts[$x].SubString(3) 
    } 
 
Return $CN 
} 