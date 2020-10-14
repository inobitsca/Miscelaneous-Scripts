clear
$Host.UI.RawUI.WindowTitle = "System Inventory Tool Designed by Chaitanyakumar Gutala"
Write-Host `n
Write-Host Author: Chaitanyakumar Gutala -BackgroundColor black -ForegroundColor white
Write-Host Contact:  powershellguy@outlook.com -BackgroundColor Black -ForegroundColor white
Write-Host `n
Write-Host This powershell script collects windows system details and writes it to an excel file.  -ForegroundColor yellow
Write-Host `n
Write-Host Prerequisites: -ForegroundColor yellow
Write-Host `n
Write-Host Admin rights on your servers and excel application installed in this local machine. -ForegroundColor yellow
write-host `n
Write-Host "If you dont have the prerequisites, please cancel this script by closing this window and run it when you have all the prerequisites." -ForegroundColor yellow
write-host `n
Read-Host Press Enter to continue 
Write-Host "Choose hostnames(servernames list) text file" -ForegroundColor yellow
######################################################################################
#File Prompt
######################################################################################

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
$sheet7row = 2
$appsrow = 3

Start-Sleep -s 3

######################################################################################
#Folder Prompt
######################################################################################
Write-Host `n
Write-Host Choose folder to create output files -ForegroundColor yellow

function Read-FolderBrowserDialog([string]$Message, [string]$InitialDirectory)
{
    $app = New-Object -ComObject Shell.Application
    $folder = $app.BrowseForFolder(0, $Message, 0, $InitialDirectory)
    if ($folder) { return $folder.Self.Path } else { return '' }
}
$directory = Read-FolderBrowserDialog ("Select your folder to save output files")

######################################################################################

#get only date and time
$a = Get-Date
$Date = $a.ToShortDateString()
$Time = $a.ToShortTimeString()

#Creating new excel object
start-sleep -Seconds 3
Write-Host `n
Write-Host "Please wait.. " -ForegroundColor magenta
$excel = New-Object -ComObject excel.application
$excel.visible = $false
$workbook = $excel.Workbooks.Add()
$workbook.Worksheets.Add() | Out-Null
$workbook.Worksheets.Add() | Out-Null
$workbook.Worksheets.Add() | Out-Null
$workbook.Worksheets.Add() | Out-Null
$workbook.Worksheets.Add() | Out-Null
$workbook.Worksheets.Add() | Out-Null
$workbook.Worksheets.Add() | Out-Null
$excel.DisplayAlerts = $False
$excel.Rows.Item(1).Font.Bold = $true 

$value1= $workbook.Worksheets.Item(1)
$value1.Name = 'Server Information'
$value1.Cells.Item(1,1) = "Machine Name"
$value1.Cells.Item(1,2) = "OS Running"
$value1.Cells.Item(1,3) = "Total Physical Memory"
$value1.Cells.Item(1,4) = "Last Boot Time"
$value1.Cells.Item(1,5) = "Bios Version"
$value1.Cells.Item(1,6) = "Serial Number"
$value1.Cells.Item(1,7) = "CPU Name"
$value1.Cells.Item(1,8) = "CPU Count"
$value1.Cells.Item(1,9) = "CPU Max Speed"
$value1.Cells.Item(1,10) = "Disk Info"
$value1.Cells.Item(1,11) = "System Model"
$value1.Cells.Item(1,12) = "Manufacturer"
$value1.Cells.Item(1,13) = "Description"
$value1.Cells.Item(1,14) = "PrimaryOwnerName"
$value1.Cells.Item(1,15) = "Systemtype"



$row = 2
$sheet2row = 2
$Page2row = 2
$misc1row = 2
$serverCount123 = 2
$sheet6column = 2
$sheet6row = 2
$appscolumn = 1
$serverCount = 1

write-host `n
Write-Host "Excel application created successfully. Writing data to rows and columns.." -ForegroundColor magenta

foreach ($computer in $filepath) {
write-host `n

if (Test-Connection -ComputerName $computer -Quiet) 
 {
write-host Processing server $computer -ForegroundColor yellow
$column = 1

$Opt = New-CimSessionOption -Protocol Dcom
$Session = New-CimSession -ComputerName $computer -SessionOption $Opt
write-host "Processing Server Information"  -ForegroundColor Green
 $OS = Get-CimInstance -Class Win32_OperatingSystem –CimSession $session
 $OS1 = Get-CimInstance -class Win32_PhysicalMemory –CimSession $session |Measure-Object -Property capacity -Sum
 $Bios = Get-CimInstance -Class Win32_BIOS –CimSession $session
 $SerialNumber = $Bios | Select-Object -ExpandProperty serialnumber
 $CS = Get-CimInstance -Class Win32_ComputerSystem –CimSession $session
 $CPU = Get-CimInstance -Class Win32_Processor –CimSession $session
 $drives = Get-CimInstance -Class Win32_LogicalDisk –CimSession $session
 $OSRunning = $OS.caption + " " + $OS.OSArchitecture + " SP " + $OS.ServicePackMajorVersion
 $TotalAvailMemory = ([math]::round(($OS1.Sum / 1GB),2))
   
 $TotalMem = "{0:N2}" -f $TotalAvailMemory
  $date = Get-Date

 #Posh 3 directly gives date values in dd/mm/yy format. So, no need to use converttodatetime function. If you are using ISE < posh3, then use converttodatetime function.
 #$uptime = $OS.ConvertToDateTime($OS.lastbootuptime)
 $uptime = $OS.LastBootUpTime
 #$BiosVersion = $Bios.Manufacturer + " " + $Bios.SMBIOSBIOSVERSION + " " + $Bios.ConvertToDateTime($Bios.Releasedate)
 $BiosVersion = $Bios.Manufacturer + " " + $Bios.SMBIOSBIOSVERSION + " " + $Bios.Releasedate
  $CPUCount = $cpu | select name | measure | Select -ExpandProperty count
  $CPUInfo = $CPU.Name 
 $CPUMaxSpeed = ($CPU[0].MaxClockSpeed/1000) 
 $Model = $CS.Model
 $Manufacturer = $CS.Manufacturer
 $Description = $CS.Description
 $PrimaryOwnerName = $CS.PrimaryOwnerName
 $Systemtype = $CS.Systemtype
 
 $value1.Cells.Item($row, $column) = $computer
 $column++
 $value1.Cells.Item($row, $column) = $OSRunning
 $column++
 $value1.Cells.Item($row, $column) = "$TotalMem GB"
 $column++
 $value1.Cells.Item($row, $column) = $uptime
 $column++
 $value1.Cells.Item($row, $column) = $BiosVersion
 $column++
 $value1.Cells.Item($row, $column) = "$SerialNumber"
 $column++
 $value1.Cells.Item($row, $column) = $CPUInfo
 $column++
 $value1.Cells.Item($row, $column) = $CPUCount
 $column++
 $value1.Cells.Item($row, $column) = $CPUMaxSpeed
 $column++
 
 $driveStr = ""
 foreach($drive in $drives)
 {
 if ($drive.size -ne $null) {
 $size1 = $drive.size / 1GB
 $size = "{0:N2}" -f $size1
 $free1 = $drive.freespace / 1GB
 $free = "{0:N2}" -f $free1
 $freea = $free1 / $size1 * 100
 $freeb = "{0:N2}" -f $freea
 $ID = $drive.DeviceID
 $driveStr += "$ID = Total Space: $size GB / Free Space: $free GB / Free (Percent): $freeb % ` "
 } else {
  $freea = "NA"
 $freeb = "NA"
 $ID = $drive.DeviceID
 $driveStr += "$ID = Total Space: NA / Free Space: NA / Free (Percent): NA ` "
 }
 }


 $value1.Cells.Item($row, $column) = $driveStr
 $column++
 $value1.Cells.Item($row, $column) = $Model
 $column++
 $value1.Cells.Item($row, $column) = $Manufacturer
 $column++
 $value1.Cells.Item($row, $column) = $Description
 $column++
 $value1.Cells.Item($row, $column) = $PrimaryOwnerName
 $column++
 $value1.Cells.Item($row, $column) = $Systemtype
 $column++
 $row++


 }}


#write data to excel file and save it 
$usedRange = $value1.UsedRange
$usedRange.EntireColumn.AutoFit() | Out-Null
$workbook.SaveAs("$directory\ServerConfiguration.xlsx") 
$excel.Quit()
Write-Host `n 
Write-Host "ServerConfiguration Report completed successfully" -ForegroundColor yellow
#release the excel object created and remove variable
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel)
Remove-Variable excel


Remove-Item "$directory\filenames.txt"
Write-Host Files saved in Folder $directory -ForegroundColor Cyan
Write-Host `n
Write-Host FileNames: -ForegroundColor yellow
Write-Host ServerConfiguration.xlsx -ForegroundColor yellow
Write-Host `n
Write-Host "Post your queries or feedback to powershellguy@outlook.com" -ForegroundColor white -BackgroundColor blue
Write-Host `n
Read-Host "Press Enter to exit"
