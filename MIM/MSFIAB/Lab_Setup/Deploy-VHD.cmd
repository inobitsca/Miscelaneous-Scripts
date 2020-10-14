SET Source=C:\MSFiaB 
SET Target=C$\MSFiaB
FOR %%C IN (Administrator2 Administrator3 Administrator4 Administrator5 Administrator6 Administrator7 Administrator8 Administrator9 Administrator10 Administrator11 Administrator12) DO @ECHO START ROBOCOPY %Source% \\%%C\%Target% /MIR