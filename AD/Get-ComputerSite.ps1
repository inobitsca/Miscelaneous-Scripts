function Get-ComputerSite($ComputerName){
   #http://www.powershellmagazine.com/2013/04/23/pstip-get-the-ad-site-name-of-a-computer/

   $site = nltest /server:$ComputerName /dsgetsite 2>$null
   if($LASTEXITCODE -eq 0){ $site[0] }
}


#Import Module
Import-Module ActiveDirectory

#Set Variables
$Domain = (Get-ADDomain).distinguishedname
$OU = "OU=PF Servers,$Domain"
$Logfile = "C:\temp\ComputerSiteAssignments.csv"

$Computer = Get-ADComputer -Filter * -SearchBase $OU -Property Name,OperatingSystem,Description,IPv4Address 

$Head = "name,OS,description,IP,site"
$Head > $logfile
Foreach ($comp in $computer) {
$Name = $Comp.Name
$OS = $Comp.OperatingSystem
$desc = $Comp.Description
$IP = $Comp.IPv4Address 
If ($IP) {
$CompSite =  Get-ComputerSite -ComputerName $Name
}
else {$CompSite = "#N/A"
$IP = "#N/A" }
If (!$CompSite) {$CompSite = "#N/A"}

$out = $name + "," + $OS + "," +  $desc  + "," + $IP  + "," + $CompSite
$out >> $logfile
}



