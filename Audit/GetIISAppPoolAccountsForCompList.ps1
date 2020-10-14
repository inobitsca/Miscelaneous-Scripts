
function Read-OpenFileDialog([string]$WindowTitle, [string]$InitialDirectory, [string]$Filter = "All files (*.*)|*.*", [switch]$AllowMultiSelect)
{  
    Add-Type -AssemblyName System.Windows.Forms
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Title = $WindowTitle
    if ($InitialDirectory -eq $Null) { $openFileDialog.InitialDirectory = $InitialDirectory } 
    $openFileDialog.Filter = $Filter
    if ($AllowMultiSelect) { $openFileDialog.MultiSelect = $true }
    $openFileDialog.ShowHelp = $true    # Without this line the ShowDialog() function may hang depending on system configuration and running from console vs. ISE.
    $openFileDialog.ShowDialog() > $null
    if ($AllowMultiSelect) { return $openFileDialog.Filenames } else { return $openFileDialog.Filename }
}

$var = Read-OpenFileDialog("Select hostnames file:","c:\Temp")

$filepath = Get-Content $var
 $countDown = $filepath |measure
 $count1=$countdown.count
 $count = 1
foreach ($computer in $filepath) {
write-host "Processing IIS App Pool Details for server $computer - $Count of $count1)"  -ForegroundColor Green
$P = Invoke-Command -ComputerName $computer -ScriptBlock {
$I1 = test-path "C:\Windows\system32\inetsrv\appcmd.exe"
If ($I1 -eq $true) {
$T1 = Test-Path c:\temp
If ($T1 -eq $false ){MD C:\temp}
$Head = "Property:Value"
$head > c:\temp\APPpoolList.txt
$APT = C:\Windows\system32\inetsrv\appcmd list apppool /text:*
$APT >> c:\temp\APPpoolList.txt 
$APL = import-csv c:\temp\APPpoolList.txt -delimiter ":"
#del c:\temp\APPpoolList.txt
$API = $APL  |Where {$_.Property -eq "username" -and $_.Value -like "*jse*"}
$API
}}
$P |export-csv -Append C:\Temp\APPpoolIDs.csv
$count = $count + 1
}