Get-ChildItem D:\AIS\Data -Recurse -File | Where CreationTime -lt  (Get-Date).AddDays(-90) |del
