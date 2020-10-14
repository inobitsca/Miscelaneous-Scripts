SELECT 

COUNT(NAME) as 'Qty',
[AX_USERID]
FROM [MicrosoftDynamicsAX].[dbo].[vw_AXUserAccountInformation]
GROUP BY name,AX_USERID
HAVING COUNT([NAME]) > 1