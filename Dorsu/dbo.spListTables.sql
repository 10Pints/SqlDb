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
CREATE PROC [dbo].[spListTables]
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn  VARCHAR(35) = 'spListTables'
      ,@sql VARCHAR(8000)
   ;

   EXEC sp_log 1, @fn, '000: starting';
   SELECT TABLE_NAME, CONCAT('SELECT COUNT(*) FROM [', TABLE_NAME,']') AS [sql]
   FROM [INFORMATION_SCHEMA].[TABLES] 
   --CROSS APPLY 
   WHERE TABLE_SCHEMA='dbo' AND TABLE_TYPE='BASE TABLE'
   ;
   
   EXEC sp_log 1, @fn, '000: leaving';
END
/*
EXEC tSQLt.Run 'test.test_030_sp_GetTeams';
EXEC test.test_030_sp_GetTeams;

SELECT * FROM dbo.fnGetTeams(NULL,NULL,NULL,NULL,NULL,NULL);
SELECT * FROM dbo.fnGetTeams('3B',NULL,NULL,NULL,NULL,NULL);
SELECT * FROM dbo.fnGetTeams(NULL,NULL,NULL,NULL,'2023-1531',NULL);
EXEC sp_GetTeams ;

EXEC dbo.sp_GetTeams @student_nm ='Misoles';
EXEC dbo.sp_GetTeams @student_nm ='Misoles';
EXEC dbo.sp_GetTeams @event_nm = 'Project X Requirements Presentation IT 3C';

*/

GO
