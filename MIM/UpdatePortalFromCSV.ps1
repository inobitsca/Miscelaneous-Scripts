PARAM($CSVFile,$FIMServer="localhost",$Delimiter=";",$LogFile="ImportCSV-Attributes.log")

function GetAttribute
{
  PARAM($exportObject,[string] $name)
  END
  {
    $attribute = $exportObject.ResourceManagementObject.ResourceManagementAttributes | 
        Where-Object {$_.AttributeName -eq $name}
    if ($attribute -ne $null -and $attribute.Value) {
        $attribute.Value
    }
  }
}

function SetAttribute
{
    PARAM($object, $attributeName, $attributeValue)
    END
    {
        $importChange = New-Object Microsoft.ResourceManagement.Automation.ObjectModel.ImportChange
        $importChange.Operation = 1
        $importChange.AttributeName = $attributeName
        $importChange.AttributeValue = $attributeValue
        $importChange.FullyResolved = 1
        $importChange.Locale = "Invariant"
        if ($object.Changes -eq $null) {$object.Changes = (,$importChange)}
        else {$object.Changes += $importChange}
    }
} 

function WriteLog
{
    PARAM($msg)
    END
    {
        Add-Content -Path $LogFile -Encoding ASCII -value $msg
        write-host $msg
    }
}


if (Test-Path $LogFile) {Remove-Item $LogFile}

if(@(get-pssnapin | where-object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {add-pssnapin FIMAutomation}

$URI = "http://" + $FIMServer + ":5725/ResourceManagementService"

# Parse CSV file. Note we're not using import-csv because we don't know what the column headers will be.
$csv = Get-Content $CSVFile
$header = $csv[0].split($Delimiter)
$numcols = $header.length
$rowcount = 1

while ($rowcount -lt $csv.length)
{
  $rowvals = $csv[$rowcount].split($Delimiter)
  $filter = "/" + $rowvals[0] + "[" + $rowvals[1] + "='" + $rowvals[2] + "']"
  WriteLog -msg "Searching on $filter"
  
  $FIMObject = $null
  $FIMObject = export-fimconfig -uri $URI -customconfig ($filter) -ErrorVariable Err -ErrorAction SilentlyContinue
  if ($FIMObject.length -gt 1) {$FIMObject = $FIMObject[0]}
  $FIMObjectID = GetAttribute $FIMObject "ObjectID"
  $FIMObjectType = GetAttribute $FIMObject "ObjectType"
 
  if (($FIMObject -eq $null) -or ($FIMObjectID -eq $null))
  {
    WriteLog -msg " Not found"
  }
  else
  {
    $bUpdateNeeded = $false
    
    # Create Import object that will update object in FIM
    $importObject = New-Object Microsoft.ResourceManagement.Automation.ObjectModel.ImportObject
    $importObject.ObjectType = $FIMObjectType
    $importObject.TargetObjectIdentifier = $FIMObjectID
    $importObject.SourceObjectIdentifier = $FIMObjectID
    $importObject.State = [Microsoft.ResourceManagement.Automation.ObjectModel.ImportState]::Put

    # Add the attributes
    $colcount = 3
    while ($colcount -lt $rowvals.length)
    {
      $currentVal = $null
      $currentVal = $FIMObject.ResourceManagementObject.ResourceManagementAttributes | where-object {$_.AttributeName -eq $header[$colcount]}

      if ($rowvals[$colcount].length -eq 0) 
      {
        $message = " No value to set for " + $header[$colcount]
        WriteLog -msg $message
      }
      elseif (($currentVal -ne $null) -and ($rowvals[$colcount] -eq $currentVal.Value)) 
      {
        $message = " Value for " + $header[$colcount] + " is already correct"
        WriteLog -msg $message
      }
      else
      {
        $bUpdateNeeded = $true
        $message = " Setting " + $header[$colcount] + " to " + $rowvals[$colcount]
        WriteLog -msg $message
        SetAttribute -object $importObject -attributeName $header[$colcount] -attributeValue $rowvals[$colcount]
      }
      $colcount += 1
    }
  
    # Import the changes into FIM
    if ($bUpdateNeeded) 
    {
      WriteLog -msg " Importing changes"
      $importObject | Import-FIMConfig -uri $URI
    }
  }

  $rowcount += 1
}




