function Create-VHDBootEntry($vhdLocation, $driveLetter)
{
	Set-ExecutionPolicy bypass

	
	if((Test-Path $vhdLocation) -eq $False)
	{
		"Please check the path and file name specified. Unable to find VHD specified"
		return
	}

	if(Get-PSDrive | Where {$_.Name -eq $driveLetter})
	{
		"The specified drive letter is in use, please select one which is free to assign."
		return
	}


	$diskpart = [System.IO.Path]::GetTempFileName()
	$diskpart = [System.IO.Path]::ChangeExtension($diskpart, ".txt")

	"select vdisk file=$vhdLocation`n
attach vdisk`n
select part 1`n
sel vol`n
assign letter $driveLetter`n
active`n
exit" | out-file -encoding ASCII $diskpart;
	diskpart /s $diskpart

$s = read-host "Please enter path to the mounted VHD Windows Installation, i.e x:\windows"
bcdboot $s
write-host $s
}
{
		"Boot from VHD script Successfull, Rebooting will allow you to boot into VHD image"
		return
	}

