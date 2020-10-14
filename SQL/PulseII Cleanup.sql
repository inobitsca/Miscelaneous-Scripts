use PulseII

Go

Delete from dbo.datTrxs where basketcreatedate < '2011-03-01 00:00:00.000'

/* use pulseii
go

 SET NOCOUNT ON 
DBCC UPDATEUSAGE(0) 

-- DB size.
EXEC sp_spaceused

-- Table row counts and sizes.
CREATE TABLE #t 
( 
    [name] NVARCHAR(128),
    [rows] CHAR(11),
    reserved VARCHAR(18), 
    data VARCHAR(18), 
    index_size VARCHAR(18),
    unused VARCHAR(18)
) 

INSERT #t EXEC sp_msForEachTable 'EXEC sp_spaceused ''?''' 

SELECT *
FROM   #t order by 'Name'

-- # of rows.
SELECT SUM(CAST([rows] AS bigint)) AS [rows]
FROM   #t 
 
DROP TABLE #t 

*/

-- ALTER DATABASE PulseII SET RECOVERY FULL ;


-- DBCC SHRINKFILE (pulseII_log, 1) 

-- Select top 1000 * from dbo.datTrxs 

-- SELECT COUNT(*) FROM dbo.datTrxs

--
ALTER DATABASE PulseII
SET MULTI_USER;
GO

