/* USE [master]
GO
EXEC master.dbo.sp_detach_db @dbname = N'PulseII', @keepfulltextindexfile=N'true'
GO
use Master
GO
ALTER DATABASE PulseII
SET Single_USER;
GO



*/
use PulseII

Go

Delete from dbo.datTrxs where basketcreatedate < '2011-03-01 00:00:00.000'

SELECT COUNT(*) FROM dbo.datTrxs