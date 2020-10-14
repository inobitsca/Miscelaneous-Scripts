#
#export-organizationalUnit2CSV.ps1
#
Import-Module ActiveDirectory
$CurrentDomain       = [System.DirectoryServices.ActiveDirectory.Domain]::getcurrentdomain()
$DC                  = $CurrentDomain.FindDomainController().name + “:389? #”localhost:389?
$Forest              = $CurrentDomain.Forest.ToString()
$Forest              = “dc=” + $Forest
$Forest              = $Forest.Replace(“.”,”,dc=”)
$domain              = [ADSI]“LDAP://$dc/$Forest”
$Dom                 = “LDAP://” + $Forest
$Root                = New-Object DirectoryServices.DirectoryEntry $Dom
$searcher            = New-Object DirectoryServices.DirectorySearcher
$searcher.PageSize   = 1000
$searcher.filter     = “(objectcategory=organizationalUnit)”
$searcher.SearchRoot = $root
$objs= $searcher.findall()
$domainDN = $domain.distinguishedName
“Path, OU, Type” | Out-File c:psOUs.csv
ForEach($OU in $Objs){
  $tmpProps = $OU.Properties
  $tmpProps.name
  $tmpType = $tmpProps.objectcategory | Out-String
  $tmpType = $tmpType.Trim()
  $tmpType = $tmpType.Substring(0,$tmpType.IndexOf(“,CN=”))
  $tmpType = $tmpType.Replace(“CN=”,””)
  $tmpOU   = $OU.Path
  $tmpOU   = $tmpOU.Replace(“LDAP://”,””)
  $tmpOU   = $tmpOU.Replace(“,$domainDN”,””)
  $tmpPath = $tmpOU.Split(“,”)
  $x=””;For($i=$tmpPath.Length;$i–;$i -le 0){$x+= “” + $tmpPath[$i]}
  $x = $x.replace(“OU=”,””)
  $tmpCSV = [CHAR]34 + $x + [CHAR]34 + “,” + [CHAR]34 + $tmpOU + [CHAR]34 + “,” + $tmpType
  $tmpCSV | Out-File OUs.csv -append
}#ForEach
notepad c:psous.csv