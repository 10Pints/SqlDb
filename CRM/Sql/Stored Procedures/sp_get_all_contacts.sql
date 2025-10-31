-- ================================================
-- Author:      Terry Watts
-- Create date: 29-SEP-2025
-- Description: Returns a list of all the contacts
--              from the country table.
-- Design:      
-- Tests:       
-- ================================================
CREATE PROCEDURE [dbo].[sp_get_all_contacts]
AS
BEGIN
   SET NOCOUNT ON;
   SELECT * FROM Contact;
END
/*
EXEC dbo.sp_get_all_contacts;
EXEC tSQLt.Run 'test.test_<proc_nm>';
*/
