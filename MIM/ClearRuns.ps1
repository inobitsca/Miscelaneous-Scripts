#--------------------------------------------------------------------------------------------------------------------
 Clear-Host
 
 $args = 60

 $DeleteDay = Get-Date

 If($args.count -gt 0) 

 {

  $DayDiff = New-Object System.TimeSpan $args[0], 0, 0, 0, 0

  $DeleteDay = $DeleteDay.Subtract($DayDiff)

 }

 

 Write-Host "Deleting run history earlier than or equal to:" $DeleteDay.toString('MM/dd/yyyy')

 $lstSrv = @(get-wmiobject -class "MIIS_SERVER" -namespace "root\MicrosoftIdentityIntegrationServer" -computer ".") 

 Write-Host "Result: " $lstSrv[0].ClearRuns($DeleteDay.toString('yyyy-MM-dd')).ReturnValue

#--------------------------------------------------------------------------------------------------------------------

 Trap 

 { 

  Write-Host "`nError: $($_.Exception.Message)`n" -foregroundcolor white -backgroundcolor darkred

  Exit

 }

#--------------------------------------------------------------------------------------------------------------------

