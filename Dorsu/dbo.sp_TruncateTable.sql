SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==========================================================
-- Author:         Terry Watts
-- Create date:    18-APR-2027
-- Description:    Truncates the given table
-- Preconditions:
--    PRE01: all Table Relationships removed
--    PRE02: @table_nm is suitably qualified and bracketed
-- Postconditions:
--    POST01: table empty
--    POST02: success loggged
-- EXEC tSQLt.Run 'test.test_<nnn>_<proc_nm>';
-- Design:         EA: Model.Conceptual Model.Truncate table
-- Tests:          test_040_sp_TruncateTable
-- ==========================================================
CREATE PROCEDURE [dbo].[sp_TruncateTable] @table_nm VARCHAR(60)
AS
BEGIN
   SET NOCOUNT OFF;
   DECLARE
       @fn  VARCHAR(35) = 'sp_TruncateTable'
      ,@sql VARCHAR(4000)
   ;

   SET @sql = CONCAT('TRUNCATE TABLE ', @table_nm, ';');
   EXEC(@sql);

   -- POST01: table empty
   EXEC sp_assert_tbl_not_pop @table_nm, @display_row_cnt=0;
   EXEC sp_log 1, @fn, '100: truncated table ', @table_nm,'';
END
/*
EXEC test.sp__crt_tst_rtns 'dbo.sp_TruncateTable';
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<proc_nm>';
EXEC TruncateTable
*/

GO
