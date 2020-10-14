USE [msdb]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE [dbo].uspEmailSQLServerHealth
(
@ServerIP VARCHAR(100), -- SQL Server 2005 Database Server IP Address
@Project VARCHAR(100), -- Name of project or cleint 
@Recepients VARCHAR(2000), -- Recepient(s) of this email (; separated in case of multiple recepients).
@MailProfile VARCHAR(100), -- Mail profile name which exists on the target database server
@Owner VARCHAR(200) -- Owner, basically name/email of the DBA responsible for the server
)  
 
/*
 
exec EmailSQLServerHealth 'inobits-com.mail.protection.outlook.com',  'NCEMS SQL Health - Test', 'cedrica@inobits.com', 'TestMailProfile', 'ISSQL01'
 
 
*/
 
AS   
BEGIN
	 
SET NOCOUNT ON
	 
/* Drop all the temp tables(not necessary at all as local temp tables get dropped as soon as session is released, 
however, good to follow this practice). */
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = '#jobs_status')    
BEGIN   
    DROP TABLE #jobs_status    
	END   
 
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = '#diskspace')    
BEGIN   
    DROP TABLE #diskspace
	END   
	   
	IF EXISTS (SELECT NAME FROM sysobjects WHERE name = '#url')    
	BEGIN   
	    DROP TABLE #url
	END   
	 
IF EXISTS (SELECT NAME FROM sysobjects WHERE name = '#dirpaths')    
BEGIN   
    DROP TABLE #dirpaths
	END   
 
-- Create the temp tables which will be used to hold the data. 
CREATE TABLE #url
(
    idd INT IDENTITY (1,1), 
    url VARCHAR(1000)
)
	 
CREATE TABLE #dirpaths 
(
    files VARCHAR(2000)
)
 
CREATE TABLE #diskspace
(
    drive VARCHAR(200), 
    diskspace INT
)
 
-- This table will hold data from sp_help_job (System sp in MSDB database)
CREATE TABLE #jobs_status    
(    
    job_id UNIQUEIDENTIFIER,    
    originating_server NVARCHAR(30),    
    name SYSNAME,    
    enabled TINYINT,    
    description NVARCHAR(512),    
    start_step_id INT,    
    category SYSNAME,    
    owner SYSNAME,    
    notify_level_eventlog INT,    
    notify_level_email INT,    
    notify_level_netsend INT,    
    notify_level_page INT,    
    notify_email_operator SYSNAME,    
    notify_netsend_operator SYSNAME,    
    notify_page_operator SYSNAME,    
    delete_level INT,    
    date_created DATETIME,    
    date_modified DATETIME,    
    version_number INT,    
    last_run_date INT,    
    last_run_time INT,    
    last_run_outcome INT,    
    next_run_date INT,    
    next_run_time INT,    
    next_run_schedule_id INT,    
    current_execution_status INT,    
    current_execution_step SYSNAME,    
    current_retry_attempt INT,    
    has_step INT,    
    has_schedule INT,    
    has_target INT,    
    type INT   
)    
 
-- To insert data in couple of temp tables created above.
INSERT #diskspace(drive, diskspace) EXEC xp_fixeddrives     
INSERT #jobs_status EXEC msdb.dbo.sp_help_job  
 
-- Variable declaration   
DECLARE @TableHTML  VARCHAR(MAX),    
        @StrSubject VARCHAR(100),    
        @Oriserver VARCHAR(100),
        @Version VARCHAR(250),
        @Edition VARCHAR(100),
        @ISClustered VARCHAR(100),
        @SP VARCHAR(100),
        @ServerCollation VARCHAR(100),
        @SingleUser VARCHAR(5),
        @LicenseType VARCHAR(100),
        @StartDate DATETIME,
        @EndDate DATETIME,
        @Cnt int,
        @URL varchar(1000),
        @Str varchar(1000)
	         
-- Variable Assignment
SELECT @Version = @@version
SELECT @Edition = CONVERT(VARCHAR(100), serverproperty('Edition'))
SELECT @StartDate = CAST(CONVERT(VARCHAR(4), DATEPART(yyyy, GETDATE())) + '-' + CONVERT(VARCHAR(2), DATEPART(mm, GETDATE())) + '-01' AS DATETIME)
SELECT @StartDate = @StartDate - 1
SELECT @EndDate = CAST(CONVERT(VARCHAR(5),DATEPART(yyyy, GETDATE() + 1)) + '-' + CONVERT(VARCHAR(2),DATEPART(mm, GETDATE() + 1)) + '-' + CONVERT(VARCHAR(2), DATEPART(dd, GETDATE() + 1)) AS DATETIME)  
SET @Cnt = 0
	 
IF serverproperty('IsClustered') = 0 
BEGIN
    SELECT @ISClustered = 'No'
	END
ELSE
BEGIN
	    SELECT @ISClustered = 'YES'
END
	 
SELECT @SP = CONVERT(VARCHAR(100), SERVERPROPERTY ('productlevel'))
SELECT @ServerCollation = CONVERT(VARCHAR(100), SERVERPROPERTY ('Collation')) 
SELECT @LicenseType = CONVERT(VARCHAR(100), SERVERPROPERTY ('LicenseType')) 
SELECT @SingleUser = CASE SERVERPROPERTY ('IsSingleUser')
                        WHEN 1 THEN 'Yes'
                        WHEN 0 THEN 'No'
                        ELSE
                        'null' END
SELECT @OriServer = CONVERT(VARCHAR(50), SERVERPROPERTY('servername'))  
SELECT @strSubject = 'DB Server Daily Health Checks ('+ CONVERT(VARCHAR(50), SERVERPROPERTY('servername')) + ')'   
   
/*
Along with refrences to SQL Server System objects, You will also see lots of HTML code however do not worry, 
Even though I am a primarily a SQL Server DBA, I am little fond of HTML, 
so thought to show some of my HTML skills here :), trust me you would love to see the end product....
*/
SET @TableHTML =    
   '<font face="Verdana" size="4">Server Info</font>  
   <table border="1" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="#111111" width="47%" id="AutoNumber1" height="50">  
    <tr>  
    <td width="27%" height="22" bgcolor="#000080"><b>  
    <font face="Verdana" size="2" color="#FFFFFF">Server IP</font></b></td>  
    <td width="39%" height="22" bgcolor="#000080"><b>  
    <font face="Verdana" size="2" color="#FFFFFF">Server Name</font></b></td>  
    <td width="90%" height="22" bgcolor="#000080"><b>  
    <font face="Verdana" size="2" color="#FFFFFF">Project/Client</font></b></td>  
    </tr>  
    <tr>  
    <td width="27%" height="27"><font face="Verdana" size="2">'+@ServerIP+'</font></td>  
    <td width="39%" height="27"><font face="Verdana" size="2">' + @OriServer +'</font></td>  
    <td width="90%" height="27"><font face="Verdana" size="2">'+@Project+'</font></td>  
    </tr>  
    </table> 
 
    <table id="AutoNumber1" style="BORDER-COLLAPSE: collapse" borderColor="#111111" height="40" cellSpacing="0" cellPadding="0" width="933" border="1">
    <tr>
    <td width="50%" bgColor="#000080" height="15"><b>
    <font face="Verdana" color="#ffffff" size="1">Version</font></b></td>
    <td width="17%" bgColor="#000080" height="15"><b>
    <font face="Verdana" color="#ffffff" size="1">Edition</font></b></td>
    <td width="18%" bgColor="#000080" height="15"><b>
    <font face="Verdana" color="#ffffff" size="1">Service Pack</font></b></td>
    <td width="93%" bgColor="#000080" height="15"><b>
    <font face="Verdana" color="#ffffff" size="1">Collation</font></b></td>
    <td width="93%" bgColor="#000080" height="15"><b>
    <font face="Verdana" color="#ffffff" size="1">LicenseType</font></b></td>
    <td width="30%" bgColor="#000080" height="15"><b>
    <font face="Verdana" color="#ffffff" size="1">SingleUser</font></b></td>
    <td width="93%" bgColor="#000080" height="15"><b>
<font face="Verdana" color="#ffffff" size="1">Clustered</font></b></td>
    </tr>
    <tr>
    <td width="50%" height="27"><font face="Verdana" size="1">'+@version +'</font></td>
    <td width="17%" height="27"><font face="Verdana" size="1">'+@edition+'</font></td>
    <td width="18%" height="27"><font face="Verdana" size="1">'+@SP+'</font></td>
    <td width="17%" height="27"><font face="Verdana" size="1">'+@ServerCollation+'</font></td>
    <td width="25%" height="27"><font face="Verdana" size="1">'+@LicenseType+'</font></td>
    <td width="25%" height="27"><font face="Verdana" size="1">'+@SingleUser+'</font></td>
    <td width="93%" height="27"><font face="Verdana" size="1">'+@isclustered+'</font></td>
    </tr>
    </table>
 
    <p style="margin-top: 0; margin-bottom: 0"> </p>' +    
    '<table style="BORDER-COLLAPSE: collapse" borderColor="#111111" cellPadding="0" width="933" bgColor="#ffffff" borderColorLight="#000000" border="1">  
    <tr>  
    <th align="left" width="432" bgColor="#000080">  
    <font face="Verdana" size="1" color="#FFFFFF">Job Name</font></th>  
    <th align="left" width="91" bgColor="#000080">  
    <font face="Verdana" size="1" color="#FFFFFF">Enabled</font></th>  
    <th align="left" width="85" bgColor="#000080">  
    <font face="Verdana" size="1" color="#FFFFFF">Last Run</font></th>  
    <th align="left" width="183" bgColor="#000080">  
    <font face="Verdana" size="1" color="#FFFFFF">Category</font></th>  
    <th align="left" width="136" bgColor="#000080">  
    <font face="Verdana" size="1" color="#FFFFFF">Last Run Date</font></th>  
    <th align="left" width="136" bgColor="#000080">  
    <font face="Verdana" size="1" color="#FFFFFF">Execution Time (Mi)</font></th>  
    </tr>
    <font face="Verdana" size="4">Job Status</font>' 
   
SELECT
    @TableHTML = @TableHTML + '<tr><td><font face="Verdana" size="1">' + 
                ISNULL(CONVERT(VARCHAR(100), A.name), '') +'</font></td>' +    
    CASE enabled  
        WHEN 0 THEN '<td bgcolor="#FFCC99"><b><font face="Verdana" size="1">False</font></b></td>' 
        WHEN 1 THEN '<td><font face="Verdana" size="1">True</font></td>' 
	    ELSE '<td><font face="Verdana" size="1">Unknown</font></td>' 
    END  +   
    CASE last_run_outcome     
        WHEN 0 THEN '<td bgColor="#ff0000"><b><blink><font face="Verdana" size="2">
	        <a href="mailto:servicedesk@mycompany.com?subject=Job failure - ' + @Oriserver + '(' + @ServerIP + ') '+ CONVERT(VARCHAR(15), GETDATE(), 101) +'&cc=db.support@mycompany.com&body = SD please log this call to DB support,' + '%0A %0A' + '<<' + ISNULL(CONVERT(VARCHAR(100), name),'''') + '>> Job Failed on ' + @OriServer + '(' + @ServerIP + ')'+ '.' +'%0A%0A Regards,'+'">Failed</a></font></blink></b></td>'
	        WHEN 1 THEN '<td><font face="Verdana" size="1">Success</font></td>' 
        WHEN 3 THEN '<td><font face="Verdana" size="1">Cancelled</font></td>' 
        WHEN 5 THEN '<td><font face="Verdana" size="1">Unknown</font></td>' 
    ELSE '<td><font face="Verdana" size="1">Other</font></td>' 
    END  +   
    '<td><font face="Verdana" size="1">' + ISNULL(CONVERT(VARCHAR(100), A.category),'') + '</font></td>' +   
    '<td><font face="Verdana" size="1">' + ISNULL(CONVERT(VARCHAR(50), A.last_run_date),'') + '</font></td>' +
    '<td><font face="Verdana" size="1">' + ISNULL(CONVERT(VARCHAR(50), X.execution_time_minutes),'') +'</font></td> </tr>'  
FROM
   #jobs_status A
    inner join (
                select
                    A.job_id,
                    datediff(mi, A.last_executed_step_date, A.stop_execution_date) execution_time_minutes 
                from
                    msdb..sysjobactivity A
    inner join (
                select
                    max(session_id) sessionid,
                    job_id 
               from
                    msdb..sysjobactivity 
                group by
                    job_id
                ) B on a.job_id = B.job_id and a.session_id = b.sessionid
    inner join (
                select
                    distinct name, 
                    job_id 
                from
                    msdb..sysjobs
                ) C on A.job_id = c.job_id
                ) X on A.job_id = X.job_id
ORDER BY
   last_run_date DESC 
 
SELECT
    @TableHTML =  @TableHTML + 
    '<table id="AutoNumber1" style="BORDER-COLLAPSE: collapse" borderColor="#111111" height="40" cellSpacing="0" cellPadding="0" width="933" border="1">
      <tr>
        <td width="35%" bgColor="#000080" height="15"><b>
        <font face="Verdana" size="1" color="#FFFFFF">Name</font></b></td>
        <td width="23%" bgColor="#000080" height="15"><b>
        <font face="Verdana" size="1" color="#FFFFFF">CreatedDate</font></b></td>
        <td width="23%" bgColor="#000080" height="15"><b>
        <font face="Verdana" size="1" color="#FFFFFF">DB Size(GB)</font></b></td>
        <td width="30%" bgColor="#000080" height="15"><b>
        <font face="Verdana" size="1" color="#FFFFFF">State</font></b></td>
        <td width="50%" bgColor="#000080" height="15"><b>
        <font face="Verdana" size="1" color="#FFFFFF">RecoveryModel</font></b></td>
      </tr>
    <p style="margin-top: 1; margin-bottom: 0"> </p>
    <font face="Verdana" size="4">Databases</font>'
 
select
@TableHTML =  @TableHTML +   
    '<tr><td><font face="Verdana" size="1">' + ISNULL(name, '') +'</font></td>' +    
    '<td><font face="Verdana" size="1">' + CONVERT(VARCHAR(2), DATEPART(dd, create_date)) + '-' + CONVERT(VARCHAR(3),DATENAME(mm,create_date)) + '-' + CONVERT(VARCHAR(4),DATEPART(yy,create_date)) +'</font></td>' +    
    '<td><font face="Verdana" size="1">' + ISNULL(CONVERT(VARCHAR(10), AA.[Total Size GB]), '') +'</font></td>' +    
    '<td><font face="Verdana" size="1">' + ISNULL(state_desc, '') +'</font></td>' +    
    '<td><font face="Verdana" size="1">' + ISNULL(recovery_model_desc, '') +'</font></td></tr>'
from
    sys.databases MST
    inner join (select b.name [LOG_DBNAME], 
                CONVERT(DECIMAL(10,2),sum(CONVERT(DECIMAL(10,2),(a.size * 8)) /1024)/1024) [Total Size GB]
                from sys.sysaltfiles A
                inner join sys.databases B on A.dbid = B.database_id
                group by b.name)AA on AA.[LOG_DBNAME] = MST.name
order by
    MST.name
 
SELECT
    @TableHTML =  @TableHTML + 
    '<table id="AutoNumber1" style="BORDER-COLLAPSE: collapse" borderColor="#111111" height="40" cellSpacing="0" cellPadding="0" width="24%" border="1">
      <tr>
        <td width="27%" bgColor="#000080" height="15"><b>
        <font face="Verdana" size="1" color="#FFFFFF">Disk</font></b></td>
        <td width="59%" bgColor="#000080" height="15"><b>
        <font face="Verdana" size="1" color="#FFFFFF">Free Space (GB)</font></b></td>
      </tr>
    <p style="margin-top: 1; margin-bottom: 0"> </p>
    <p><font face="Verdana" size="4">Disk Stats</font></p>'
 
SELECT
    @TableHTML =  @TableHTML +   
    '<tr><td><font face="Verdana" size="1">' + ISNULL(CONVERT(VARCHAR(100), drive), '') +'</font></td>' +    
    '<td><font face="Verdana" size="1">' + ISNULL(CONVERT(VARCHAR(100), ISNULL(CAST(CAST(diskspace AS DECIMAL(10,2))/1024 AS DECIMAL(10,2)), 0)),'') +'</font></td></tr>'
FROM
    #diskspace
 
SELECT @TableHTML =  @TableHTML + '</table>'
 
-- Code for SQL Server Database Backup Stats
SELECT
    @TableHTML = @TableHTML +   
    '<table style="BORDER-COLLAPSE: collapse" borderColor="#111111" cellPadding="0" width="933" bgColor="#ffffff" borderColorLight="#000000" border="1">    
    <tr>    
    <th align="left" width="91" bgColor="#000080">    
    <font face="Verdana" size="1" color="#FFFFFF">Date</font></th>    
    <th align="left" width="105" bgColor="#000080">    
    <font face="Verdana" size="1" color="#FFFFFF">Database</font></th>    
    <th align="left" width="165" bgColor="#000080">    
     <font face="Verdana" size="1" color="#FFFFFF">File Name</font></th>    
    <th align="left" width="75" bgColor="#000080">    
     <font face="Verdana" size="1" color="#FFFFFF">Type</font></th>    
    <th align="left" width="165" bgColor="#000080"> 
    <font face="Verdana" size="1" color="#FFFFFF">Start Time</font></th>    
    <th align="left" width="165" bgColor="#000080">    
    <font face="Verdana" size="1" color="#FFFFFF">End Time</font></th>    
    <th align="left" width="136" bgColor="#000080">    
   <font face="Verdana" size="1" color="#FFFFFF">Size(GB)</font></th>    
    </tr> 
<p style="margin-top: 1; margin-bottom: 0"> </p>
    <p><font face="Verdana" size="4">SQL SERVER Database Backup Stats</font></p>'
 
 
SELECT
   @TableHTML =  @TableHTML +     
   '<tr>  
    <td><font face="Verdana" size="1">' + ISNULL(CONVERT(VARCHAR(2), DATEPART(dd,MST.backup_start_date)) + '-' + CONVERT(VARCHAR(3),DATENAME(mm, MST.backup_start_date)) + '-' + CONVERT(VARCHAR(4), DATEPART(yyyy, MST.backup_start_date)),'') +'</font></td>' +      
    '<td><font face="Verdana" size="1">' + ISNULL(CONVERT(VARCHAR(100), MST.database_name), '') +'</font></td>' +      
    '<td><font face="Verdana" size="1">' + ISNULL(CONVERT(VARCHAR(100), MST.name), '') +'</font></td>' +   
    CASE Type 
    WHEN 'D' THEN '<td><font face="Verdana" size="1">' + 'Full' +'</font></td>'   
    WHEN 'I' THEN '<td><font face="Verdana" size="1">' + 'Differential' +'</font></td>'
    WHEN 'L' THEN '<td><font face="Verdana" size="1">' + 'Log' +'</font></td>'
    WHEN 'F' THEN '<td><font face="Verdana" size="1">' + 'File or Filegroup' +'</font></td>'
    WHEN 'G' THEN '<td><font face="Verdana" size="1">' + 'File Differential' +'</font></td>'
    WHEN 'P' THEN '<td><font face="Verdana" size="1">' + 'Partial' +'</font></td>'
    WHEN 'Q' THEN '<td><font face="Verdana" size="1">' + 'Partial Differential' +'</font></td>'
    ELSE '<td><font face="Verdana" size="1">' + 'Unknown' +'</font></td>'
    END + 
    '<td><font face="Verdana" size="1">' + ISNULL(CONVERT(VARCHAR(50), MST.backup_start_date), '') +'</font></td>' +  
    '<td><font face="Verdana" size="1">' + ISNULL(CONVERT(VARCHAR(50), MST.backup_finish_date), '') +'</font></td>' +  
    '<td><font face="Verdana" size="1">' + ISNULL(CONVERT(VARCHAR(10), CAST((MST.backup_size/1024)/1024/1024 AS DECIMAL(10,2))), '') +'</font></td>' +  
     '</tr>'    
FROM
    backupset MST
WHERE
    MST.backup_start_date BETWEEN @StartDate AND @EndDate
ORDER BY
    MST.backup_start_date DESC
 
SELECT @TableHTML =  @TableHTML + '</table>'
 
-- Code for physical database backup file present on disk
INSERT #url
SELECT DISTINCT
    SUBSTRING(BMF.physical_device_name, 1, len(BMF.physical_device_name) - CHARINDEX('\', REVERSE(BMF.physical_device_name), 0))
from 
    backupset MST
    inner join backupmediafamily BMF ON BMF.media_set_id = MST.media_set_id
where 
    MST.backup_start_date BETWEEN @startdate AND @enddate
 
select @Cnt = COUNT(*) FROM #url
 
WHILE @Cnt >0
BEGIN
 
   SELECT @URL = url FROM #url WHERE idd = @Cnt
    SELECT @Str = 'EXEC master.dbo.xp_cmdshell ''dir "' + @URL +'" /B/O:D'''
	 
    INSERT #dirpaths SELECT 'PATH: ' + @URL
    INSERT #dirpaths
     
    EXEC (@Str)
	     
   INSERT #dirpaths values('')
 
    SET @Cnt = @Cnt - 1
     
end
 
DELETE FROM #dirpaths WHERE files IS NULL
 
select 
    @TableHTML = @TableHTML +   
    '<table style="BORDER-COLLAPSE: collapse" borderColor="#111111" cellPadding="0" width="933" bgColor="#ffffff" borderColorLight="#000000" border="1">    
    <tr>    
    <th align="left" width="91" bgColor="#000080">    
    <font face="Verdana" size="1" color="#FFFFFF">Physical Files</font></th>
    </tr>
<p style="margin-top: 1; margin-bottom: 0"> </p>
    <p><font face="Verdana" size="4">Physical Backup Files</font></p>'    
 
SELECT 
    @TableHTML =  @TableHTML + '<tr>'  + 
    CASE SUBSTRING(files, 1, 5) 
        WHEN 'PATH:' THEN '<td bgcolor = "#D7D7D7"><b><font face="Verdana" size="1">' + files  + '</font><b></td>' 
    ELSE 
        '<td><font face="Verdana" size="1">' + files  + '</font></td>' 
    END + 
    '</tr>'  
FROM 
    #dirpaths  
 
SELECT 
    @TableHTML =  @TableHTML + '</table>' +   
    '<p style="margin-top: 0; margin-bottom: 0"> </p>
    <hr color="#000000" size="1">
    <p><font face="Verdana" size="2"><b>Server Owner:</b> '+@owner+'</font></p>  
    <p style="margin-top: 0; margin-bottom: 0"><font face="Verdana" size="2">Thanks   
    and Regards,</font></p>  
    <p style="margin-top: 0; margin-bottom: 0"><font face="Verdana" size="2">DB   
    Support Team</font></p>  
    <p> </p>'  
 
EXEC msdb.dbo.sp_send_dbmail  
    @profile_name = @MailProfile,    
    @recipients=@Recepients,    
    @subject = @strSubject,    
    @body = @TableHTML,    
    @body_format = 'HTML' ;    
	 
SET NOCOUNT OFF
END