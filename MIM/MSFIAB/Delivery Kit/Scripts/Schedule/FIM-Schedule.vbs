Set Service = GetObject("winmgmts:{authenticationLevel=PktPrivacy}!root/MicrosoftIdentityIntegrationServer")

Set FIM = Service.ExecQuery("select * from MIIS_ManagementAgent where Name = 'FIM MA'")
Set AD = Service.ExecQuery("select * from MIIS_ManagementAgent where Name = 'AD'")


' main processing
ClearRuns(7)

Run FIM, "DIDS"
Run AD, "DIDS"

Run FIM, "E.DI"

'allow for FIM to do some processing
Wait 5

Run FIM, "DS"
Run AD, "E.DI"
RUN AD, "DS"

Sub Wait(Seconds)
  WScript.Echo "Waiting " & Seconds & " seconds..."
  WScript.Sleep(Seconds*1000)
End Sub

Sub Run(MASet, Profile)
  For Each MA In MASet
    WScript.Echo "Running " + MA.name + ".Execute('" & Profile & "')..."
    WScript.Echo "Run completed with result: " + MA.Execute(Profile)
  Next
End Sub

Sub ClearRuns(DaysAgo)
  Set Server = Service.Get("MIIS_Server.Name='localhost'")
  DeleteDate = FormatDateTime(Now()-DaysAgo, 2)
  WScript.Echo "Deleting Run Histories from " & DeleteDate
  WScript.Echo "Result: " & Server.ClearRuns(DeleteDate)
End Sub
