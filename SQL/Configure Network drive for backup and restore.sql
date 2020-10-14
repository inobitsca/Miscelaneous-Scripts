-- Enable XP_CMDShell

EXEC sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO

EXEC sp_configure 'xp_cmdshell',1
GO
RECONFIGURE
GO

--MAP the Drive in WINDOWS before you execute the next section 

--exec xp_cmdshell 'net use h: \\nsvoddb01\manualbackup'

--EXEC XP_CMDSHELL 'Dir H:' 