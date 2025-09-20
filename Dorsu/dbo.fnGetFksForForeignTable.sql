SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===========================================================
-- Function   : dbo.fnGetFksForPrimaryTable
-- Description: returns the Fkeys assocoated with
--              @@foreign_tbl as the foreign table
-- Author:      Terry Watts
-- Create date: 01-MAR-2025
--
-- Preconditions: none
--
-- Postconditions
-- (@foreign_tbl exists AND (fk_nm=forign key name 
--                      AND f_tbl= foreign table name
--                      AND p_tbl = primary table name)
-- OR
-- (@foreign_tbl exists does not exist AND no rows returned)
-- ===========================================================
CREATE FUNCTION [dbo].[fnGetFksForForeignTable](@foreign_tbl NVARCHAR(60))
RETURNS @t TABLE
(
    fk_nm VARCHAR(60)
   ,f_tbl VARCHAR(60)
   ,p_tbl VARCHAR(60)
)
AS
BEGIN
   INSERT INTO @t(fk_nm, f_tbl, p_tbl)
   SELECT fk_constraint_name, foreign_table, primary_table
   FROM list_fks_vw
   WHERE foreign_table = @foreign_tbl OR @foreign_tbl IS NULL
   ORDER BY fk_constraint_name;

   RETURN;
END
/*
EXEC tSQLt.Run 'test.test_007_fnGetTableForFk';

SELECT * FROM dbo.fnGetFksForForeignTable(NULL);
SELECT * FROM dbo.fnGetFksForForeignTable('UserRole');

--EXEC test.sp__crt_tst_rtns 'dbo].[fnGetFksForForeignTable';
SELECT * FROM list_fks_vw
*/


GO
