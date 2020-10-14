Get-MessageTrackingLog -start "2018-08-25" -Sender "nerd@jse.co.za" -Server vypexc01 | Select timestamp, eventid, Source,Messageid, MessageSubject, sender,`
@{Name=’recipients‘;Expression={[string]::join(";", ($_.recipients))}}, clientip, clienthostname, serverip, serverhostname, messageinfo  `
|export-csv c:\temp\2018-08-25-nerdEmail2.csv -Append