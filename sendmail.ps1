$outfile = "C:\temp\report.csv"
$from = "MIM Service <mim@bcx.co.za>"
$to = """" + "Janus Groenewald <Janus.Groenewald@bcx.co.za>" + """" + ","  + """" + "Cedric Abrahams <cedrica@inobits.com>" + """" + ","  + """" +"<Ruan Blignaut <RuanB@netsurit.com>" + """"

Send-MailMessage -From $from -To $to -Subject "MIM Self service Password Reset Report" -Body "CSV report attached." `
-Attachments $outfile -Priority High -dno onSuccess, onFailure -SmtpServer "midrelay.africa.enterprise.root"