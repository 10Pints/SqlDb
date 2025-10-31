-- =============================================
-- Author:      Terry Watts
-- Create date: 10-SEP-2025
-- Description: Returns a list of the countries 
--              from the country table.
-- Design:      
-- Tests:       
-- =============================================
CREATE PROCEDURE [dbo].[sp_get_all_countries]
AS
BEGIN
   SET NOCOUNT ON;
   SELECT * FROM Country;
END
/*
EXEC dbo.sp_get_all_countries;
EXEC tSQLt.Run 'test.test_<proc_nm>';
*/
