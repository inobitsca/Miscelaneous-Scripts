# two-liner
$date = (Get-Date).AddMonths(-9)
dir path\folder -Recurse | ?{$_.lastwritetime -lt $date -and !$_.PsIsContainer} | Measure-Object -Property Length -Sum


# oneliner
dir path\folder -Recurse -Force -ErrorAction SilentlyContinue | `
    ?{$_.lastwritetime -lt (Get-Date).AddMonths(-3)} | Measure-Object -Property Length -Sum

# zero-liner
# ooops, I haven't zero-liner examples



# resulting data will be in bytes. To convert them to gigabytes, you may do this:
$files = dir path\folder -Recurse -Force -ErrorAction SilentlyContinue | `
    ?{$_.lastwritetime -lt (Get-Date).AddMonths(-3)} | Measure-Object -Property Length -Sum
($files.sum / 1gb).ToString("F02")
# F02 determines how much digits will appears after comma. In my case - 2 digits.