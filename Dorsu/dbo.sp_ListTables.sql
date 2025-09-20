SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==========================================================
-- Description: list the tables and their counts in dbo
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 30-MAY-2025
-- ==========================================================
CREATE PROC [dbo].[sp_ListTables]
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn  VARCHAR(35) = 'sp_ListTables'
      ,@sql VARCHAR(8000)
   ;

   EXEC sp_log 1, @fn, '000: starting';
   TRUNCATE TABLE TableInfo;

   PRINT 'TRUNCATE TABLE TableInfo;';

   SELECT CONCAT('INSERT INTO TableInfo(table_name, row_cnt)
 SELECT ''',TABLE_NAME,''', COUNT(*)
 FROM [', TABLE_NAME,'];') AS [sql]
   FROM [INFORMATION_SCHEMA].[TABLES] 
   WHERE TABLE_SCHEMA='dbo' AND TABLE_TYPE='BASE TABLE'
   ;
   PRINT 'SELECT * FROM TableInfo ORDER BY row_cnt;';

   EXEC sp_log 1, @fn, '000: leaving';
END

GO
