
$users=import-csv c:\temp\mig.txt

foreach ($user in $users) {

$mail = "*" + $user.upn + "*"

get-msoluser -all |where-object {$_.proxyaddresses -like $mail}

}
