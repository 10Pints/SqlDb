SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =========================================================
-- Function   : dbo.fnGetTableForFk
-- Description: returns the FK foreign table 
--              for the given FK
-- Author:      Terry Watts
-- Create date: 08-MAR-2025
--
-- Preconditions:
-- PRE01:

-- Postconditions:
---- POST01: if table not found throws div by zero exception
-- =========================================================
CREATE FUNCTION [dbo].[fnGetTableForFk](@fk_nm NVARCHAR(150))
RETURNS VARCHAR(60)
AS
BEGIN
   DECLARE @table_nm VARCHAR(60), @x INT
   SELECT @table_nm = foreign_table
   FROM list_fks_vw
   WHERE fk_constraint_name = @fk_nm

--   IF @table_nm IS NULL
--      SET @x = 1/0; -- BOOM

   RETURN @table_nm;
END
/*
PRINT dbo.fnGetTableForFk(NULL);
SELECT * FROM dbo.fnGetFksForForeignTable('UserRole');

EXEC test.sp__crt_tst_rtns 'dbo].[fnGetTableForFk';
*/


GO
