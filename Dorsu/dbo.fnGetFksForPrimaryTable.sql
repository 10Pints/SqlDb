SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================
-- Function   : dbo.fnGetFksForPrimaryTable
-- Description: returns the Fkeys assocoated with
--              @Primary_tbl as the primary table
-- Author:      Terry Watts
-- Create date: 01-MAR-2025
-- ===============================================
CREATE FUNCTION [dbo].[fnGetFksForPrimaryTable](@Primary_tbl NVARCHAR(60))
RETURNS @t TABLE
(
   tbl_nm VARCHAR(60),
   fk_nm  VARCHAR(60))
AS
BEGIN
   INSERT INTO @t SELECT primary_table, fk_constraint_name 
   FROM list_fks_vw WHERE primary_table = @Primary_tbl
   ORDER BY fk_constraint_name;

   RETURN;
END
/*
SELECT * FROM dbo.fnGetFksForPrimaryTable('Course');
*/


GO
