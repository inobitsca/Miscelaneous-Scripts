
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
$outfile = "c:\Temp\ServerServices_" + (Get-Date -format s).Replace(":","-") +".csv"
$OutHead = "computer" + "," + "Name" + "," + "Caption" + "," + "State" + "," + "StartMode" + "," + "pathname" + "," + "startname"
$outHead >> $Outfile
foreach ($computer in $filepath) {
$Opt = New-CimSessionOption -Protocol Dcom
$Session = New-CimSession -ComputerName $computer -SessionOption $Opt
write-host "Processing Service Details"  -ForegroundColor Green
$serviceinfo = $null
$Serviceinfo1 = $null
$serviceinfo = Get-CimInstance -ClassName win32_service -CimSession $Session 
Foreach ($serviceinfo1 in $serviceinfo) {
$Name = $serviceinfo1.Name
$Caption = $serviceinfo1.Caption
$State = $serviceinfo1.State
$StartMode = $serviceinfo1.StartMode
$Pathname = $serviceinfo1.pathname
$startname = $serviceinfo1.startname

$Out = $computer + "," + $Name + "," + $Caption + "," + $State + "," + $StartMode + "," + $pathname + "," + $startname

$out >> $Outfile
}
}