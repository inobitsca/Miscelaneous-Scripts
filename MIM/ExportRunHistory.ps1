$Global:GetRunHistoryColumnName="" 
$Global:GetRunHistoryColumnData="" 
$Global:GetRunStepNumber=0 
 
function buildrunhistorydata( [System.Object]$xmlobject, [string]$columnname, [int]$i ) 
{ 
 if($xmlobject -eq $null){ 
 if( $Global:GetRunHistoryColumnData -eq "" ){ $Global:GetRunHistoryColumnData = $getdata } 
 else { $Global:GetRunHistoryColumnData = $Global:GetRunHistoryColumnData+"`t"+$getdata } 
 } 
 else{ 
 if( $Global:GetRunHistoryColumnName -eq "" ){ $Global:GetRunHistoryColumnName = $xmlobject[$columnname].Name } 
 else { 
 if( -not $Global:GetRunHistoryColumnName.Contains($columnname) ) { 
 if(( -not $xmlobject[$columnname].Name -eq "" ) -or ( -not $xmlobject.Name -eq "" )){ 
 $NewColumnName = if( $xmlobject[$columnname].Name -eq $null ){$xmlobject.Name} else{$xmlobject[$columnname].Name} 
 $Global:GetRunHistoryColumnName = $Global:GetRunHistoryColumnName.Trim()+"`t"+$NewColumnName }} 
 } 
 
 switch ($i) 
 { 
 0 { $getdata = $xmlobject[$columnname].InnerText } 
 1 { $getdata = $xmlobject[$columnname].InnerXML } 
 2 { $getdata = $xmlobject[$columnname].OuterXML } 
 3 { $getdata = $xmlobject[$columnname].type } 
 4 { $getdata = $xmlobject[$columnname].Value } 
 5 { $getdata = $xmlobject.Value } 
 } 
 
 if( $columnname.ToLower() -eq "call-stack" ) 
 { 
 $getdata = $getdata.Replace(" ","") 
 $getdata = $getdata.Replace("`r`n","") 
 } 
 
 if( $Global:GetRunHistoryColumnData -eq "" ){ $Global:GetRunHistoryColumnData = $getdata } 
 else { $Global:GetRunHistoryColumnData = $Global:GetRunHistoryColumnData+"`t"+$getdata } 
 } 
} 
 
 
$OutFileHistory = $env:TEMP+"\RUNHISTORY_CSV.csv" 
$OutFileCompleteRunHistory = $env:TEMP+"\RUNHISTORY_ALL.txt" 
$RunStartDate=(Get-Date (Get-Date).AddDays(-20) -Format d) 
$GetRunStartTime="RunStartTime >'"+$RunStartDate+"'" 
$GetRunHistoryNotSuccess = Get-WmiObject -class "MIIS_RunHistory" -namespace root\MicrosoftIdentityintegrationServer -Filter $GetRunStartTime 
 
if( $GetRunHistoryNotSuccess -ne $null ){ 
$sRunHistoryString="" 
$GetRunHistoryData="" 
$RunHistoryNames="" 
 
 foreach( $RHERR in $GetRunHistoryNotSuccess ){ 
 [xml]$gRunHistory = $RHERR.RunDetails().ReturnValue 
 $gRunHistoryRunDetails = $gRunHistory.DocumentElement["run-details"] 
 buildrunhistorydata $gRunHistoryRunDetails "ma-name" 0 
 buildrunhistorydata $gRunHistoryRunDetails "ma-id" 0 
 buildrunhistorydata $gRunHistoryRunDetails "run-profile-name" 0 
 buildrunhistorydata $gRunHistoryRunDetails "security-id" 0 
 #step-details ( could have multiple steps, so we will need to loop through ) 
 $GetRunStepDetails= $gRunHistoryRunDetails["step-details"] 
 #step-details information 
 $Global:GetRunStepNumber = $GetRunStepDetails.Attributes.Item(0).Value 
 
 for( [int]$iCounter=0; $iCounter -lt $GetRunStepNumber; $iCounter++ ){ 
 if( $iCounter -gt 0 ) { $GetRunStepDetails = $GetRunStepDetails.NextSibling } 
 #step-details 
 buildrunhistorydata $GetRunStepDetails.Attributes.Item(0) $GetRunStepDetails.Attributes.Item(0).Name 5 
 buildrunhistorydata $GetRunStepDetails "step-result" 0 
 buildrunhistorydata $GetRunStepDetails "start-date" 2 
 buildrunhistorydata $GetRunStepDetails "end-date" 2 
 
 #MA Connection Information 
 $GetMAConnection=$GetRunStepDetails["ma-connection"] 
 buildrunhistorydata $GetMAConnection "connection-result" 0 
 buildrunhistorydata $GetMAConnection "server" 0 
 
 #Step-Description 
 $GetRunStepDescription= $GetRunStepDetails["step-description"] 
 buildrunhistorydata $GetRunStepDescription "partition" 0 
 buildrunhistorydata $GetRunStepDescription "step-type" 3 
 
 #Custom Data 
 $GetCustomData = $GetRunStepDescription["custom-data"] 
 buildrunhistorydata $GetCustomData.FirstChild "batch-size" 0 
 buildrunhistorydata $GetCustomData.FirstChild "page-size" 0 
 buildrunhistorydata $GetCustomData.FirstChild "time-limit" 0 
 
 #inbound-flow-counters 
 buildrunhistorydata $GetRunStepDetails "inbound-flow-counters" 1 
 buildrunhistorydata $GetRunStepDetails "export-counters" 1 
 
 #Synchronization Errors 
 $GetSynchronizationErrors=$GetRunStepDetails["synchronization-errors"] 
 
 if( -not $GetSynchronizationErrors.IsEmpty ){ 
 buildrunhistorydata $GetSynchronizationErrors.FirstChild "error-type" 0 
 buildrunhistorydata $GetSynchronizationErrors.FirstChild "algorithm-step" 0 
 $GetSyncErrorInfo = $GetSynchronizationErrors.FirstChild["extension-error-info"] 
 if( $GetSyncErrorInfo -ne $null ){ buildrunhistorydata $GetSyncErrorInfo "call-stack" 0 } 
 if( -not $RunHistoryNames.Contains("call-stack") ) { $RunHistoryNames = $GetRunHistoryColumnName } } 
 if( $GetRunStepNumber -gt 1 ) { $GetRunHistoryColumnData = $GetRunHistoryColumnData+"`n`t`t`t" } 
 } 
 
 if($sRunHistoryString -eq ""){$sRunHistoryString = $GetRunHistoryColumnData }else{ $sRunHistoryString = $sRunHistoryString+"`r"+$GetRunHistoryColumnData } 
 $GetRunHistoryColumnData="" 
 if($RunHistoryNames -eq ""){ $RunHistoryNames = $GetRunHistoryColumnName }else { $RunHistoryNames = $RunHistoryNames } 
 $RHERR.RunDetails() | Out-File -Append $OutFileCompleteRunHistory 
 } 
 
 if($GetRunHistoryData -eq "") { $RunHistoryNames | Out-File -Append $OutFileHistory } 
 $GetRunHistoryData = $sRunHistoryString 
 $GetRunHistoryData | Out-File -Append $OutFileHistory 
 $sRunHistoryString = "" 
 $RunHistoryNames = "" 
}
 