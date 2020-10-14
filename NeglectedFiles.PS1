

$Days = (Get-Date).AddDays(-720)

$files =  Get-ChildItem -Path  $path -Recurse | select DirectoryName,Name,lastaccesstime,length | Where-Object {$_.LastAccessTime -le $days}

$files |export-csv .\oldfiles.csv