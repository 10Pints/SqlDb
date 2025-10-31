-- =============================================
-- Author:      Terry Watts
-- Create date: 18-OCT-2025
-- Description: 
-- EXEC tSQLt.Run 'test.test_<nnn>_<proc_nm>';
-- Design:      
-- Tests:       
-- =============================================
CREATE PROCEDURE dbo.sp_import_EventLog
AS
BEGIN
 SET NOCOUNT ON;
TRUNCATE TABLE EventLog;
TRUNCATE TABLE EventLogStaging;

BULK INSERT EventLogStaging
FROM 'C:\rustdesk-server\windows_errors_warnings.tsv'
WITH (
    FIELDTERMINATOR = '\t',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);

SELECT * FROM EventLogStaging;
INSERT INTO EventLog
(
 TimeCreated
,event_id
,event_type
,LogName
,ProviderName
,MachineName
,UserId
,[Message]
)
SELECT TRIM('"' FROM TimeCreated)
      ,TRIM('"' FROM event_id)
      ,TRIM('"' FROM event_type)
      ,TRIM('"' FROM LogName)
      ,TRIM('"' FROM ProviderName)
      ,TRIM('"' FROM MachineName)
      ,TRIM('"' FROM UserId)
      ,TRIM('"' FROM [Message])
FROM EventLogStaging;

SELECT * FROM EventLog;END
/*
EXEC sp_import_EventLog
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<proc_nm>';
*/
