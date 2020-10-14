$from = "no-reply@routemonitoring.co.za"
$recipient = "cedric@inobits.com"
$subject = "Sendgrid Test SSL"
$body = "This is a test TLS/SSL email"
$smtpserver = "smtp.sendgrid.com"
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { return $true }
Send-MailMessage -SmtpServer $smtpserver -Port 465 -UseSsl -From $from -To $recipient -Subject $subject -BodyAsHtml $body -Credential $credential -Encoding ([System.Text.Encoding]::UTF8)


$from = "no-reply@routemonitoring.co.za"
$recipient = "cedric@inobits.com"
$subject = "Sendgrid Test SSL"
$body = "This is a test TLS/SSL email"
$smtpserver = "smtp.sendgrid.com"
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { return $true }
Send-MailMessage -SmtpServer $smtpserver -Port 25 -From $from -To $recipient -Subject $subject -BodyAsHtml $body -Credential $credential -Encoding ([System.Text.Encoding]::UTF8)


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