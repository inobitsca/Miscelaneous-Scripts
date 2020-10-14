$users = import-csv coolwines.csv
foreach ($user in $users) {
$pass = (ConvertTo-SecureString -string $user.Password -AsPlainText -Force)

$user.password
$sam
$pass
$Sam=$user.sam
Set-ADAccountPassword -identity $sam -reset -NewPassword $pass
}
