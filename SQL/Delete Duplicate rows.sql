WITH cte AS
 (
    SELECT 
		[timestamp],  
		[Calling_Station_Id],
		[Acct_Session_Id],
        ROW_NUMBER() OVER 
		(
            PARTITION BY 
				[timestamp],  
				[Calling_Station_Id],
				[Acct_Session_Id]
            ORDER BY 
				[timestamp]
				)  As RN
     FROM  [dbo].[accounting_data] 
	 )
	 
DELETE FROM cte
WHERE RN > 1;