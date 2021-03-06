#------------------------------------------------------------------------------- 
# Function:    main 
# 
# Description:    Main entry point for the script.  Loads the configuration source 
#        Xml and initializes the foreach loop to iterate over a 
#         collection of Xml nodes. 
# 
# Parameters:    None 
#------------------------------------------------------------------------------- 

function main() 
{ 
  [xml]$cfg = Get-Content .\AAM.xml 

  if( $? -eq $false ) { 
    Write-Host "Cannot load configuration source Xml $cfg." 
    return $false 
  } 

  $cfg.Configuration.WebApplication | ForEach-Object { 
    new-SPAlternateUrl( $_ ) 
  } 
} 

#------------------------------------------------------------------------------- 
# Function:     New-SPAlternateURL 
# 
# Description:     This script adds the specified URLs to the collection of 
#        alternate request URLs for the Web application. 
# 
# Parameters:    None 
#------------------------------------------------------------------------------- 

function New-SPAlternateURL( [object] $cfg ) 
{ 
  [Void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.Sharepoint") 

  $webApp = $nul; 
  $webApp = [Microsoft.SharePoint.Administration.SPWebApplication]::Lookup($cfg.Url) 
  trap [Exception] {  
      Write-Host 
    Write-Error $("Exception: " + $_.Exception.Message); 
    continue; 
  } 

  $cfg.AlternateUrl | ForEach-Object { 
  $map=New-Object Microsoft.SharePoint.Administration.SPAlternateUrl($_.IncomingUrl, $_.UrlZone) 
  $webApp.AlternateUrls.Add($map) 
  return $map 
  } 
}
main
iisreset /noforce