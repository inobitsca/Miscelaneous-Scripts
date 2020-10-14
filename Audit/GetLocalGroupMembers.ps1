$a = Get-Date
$B = ([datetime]$a).tostring("yyyy-MM-dd")
$outfile = "c:\temp\LocalGroupMembers-$B.csv"
$head = "Computer,Group,member1,member2,member3,member4,member5,member6,member7,member8,member9,member10,member11,member12,member13,member14,member15"
$head >> $Outfile

Write-Host "Choose hostnames(servernames list) text file" -ForegroundColor yellow

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

foreach ($computer in $filepath) {
write-host `n

if (Test-Connection -ComputerName $computer -Quiet) 
 {
write-host Processing server $computer -ForegroundColor yellow}

function get-localadmins { 
        param( 
    [Parameter(Mandatory=$true,valuefrompipeline=$true)] 
    [string]$strComputer) 
    begin {} 
    Process { 
        $adminlist ="" 
        $computer = [ADSI]("WinNT://" + $strComputer + ",computer") 
        $AdminGroup = $computer.psbase.children.find("Administrators") 
        $Adminmembers= $AdminGroup.psbase.invoke("Members") | %{$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)} 
        foreach ($admin in $Adminmembers) { $adminlist = $adminlist + $admin + "," } 
       
        Write-Output $adminlist 
 
 
        } 
end {} 
} 
 


function get-localRDP { 
        param( 
    [Parameter(Mandatory=$true,valuefrompipeline=$true)] 
    [string]$strComputer) 
    begin {} 
    Process { 
        $RDPlist ="" 
        $computer = [ADSI]("WinNT://" + $strComputer + ",computer") 
        $RDPGroup = $computer.psbase.children.find("Remote Desktop Users") 
        $RDPmembers= $RDPGroup.psbase.invoke("Members") | %{$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)} 
        foreach ($RDPuser in $RDPmembers) { $RDPlist = $RDPlist + $RDPuser + "," } 
      
        Write-Output $RDPlist 
 
 
        } 
end {} 
} 
$RDP = "Remote Desktop Users"
$ADM = "Administrators"
$admins = get-localAdmins $computer 
$Remotes = get-localRDP $computer
$Aout = $computer +"," + $ADM + "," + $admins
$Rout = $computer +"," + $RDP + "," + $Remotes
$Aout >> $outfile
$Rout >> $outfile
}