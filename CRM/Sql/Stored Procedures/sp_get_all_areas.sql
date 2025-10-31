-- =============================================
-- Author:      Terry Watts
-- Create date: 11-SEP-2025
-- Description: -- 
-- returns all the area static data 
-- Design:      
-- Tests:       
-- =============================================
CREATE PROCEDURE dbo.sp_get_all_areas
AS
BEGIN
   DECLARE @fn VARCHAR(35)='sp_get_all_areas'
   ;

   SET NOCOUNT ON;
   EXEC sp_log 1, @fn, '000: starting';
   SELECT * FROM [Area];
   EXEC sp_log 1, @fn, '999: leaving';
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<proc_nm>';
*/
