--=======================================================================================================
-- Author:           Terry Watts
-- Create date:      18-Sep-2025
-- Rtn:              test.test_080_sp_import_merge_existing_table_from_xl
-- Description: main test routine for the dbo.sp_import_merge_existing_table_from_xl routine 
--
-- Tested rtn description:
-- Dynamically imports/merges data from Excel into an *existing* table.
-- Uses common column names for matching (order irrelevant). Supports append, replace, or true MERGE.
--
-- Params:
-- @file: Full path to Excel.
-- @worksheet: Sheet name (default: 'Sheet1').
-- @range: Cell range (default: entire sheet).
-- @table: Existing table name (required; schema-qualified OK).
-- @key_column: Single key column for MERGE (NULL = append-only INSERT).
-- @delete_first: If 1, DELETE all rows first (replace mode).
-- @display_tables: If 1, SELECT * after.
--
-- Example Execution:
-- EXEC dbo.sp_import_merge_existing_table_from_xl
--    'D:\Dev\Property\Data\PropertySales.xlsx', 'Resort', NULL, 'dbo.ResortSales', NULL, 1, 1;
-- -- (Replaces all in ResortSales, displays result)
--
-- EXEC dbo.sp_import_merge_existing_table_from_xl
--    'D:\Dev\Property\Data\PropertySales.xlsx', 'Resort', NULL, 'dbo.ResortSales', 'ID', 0, 1;
-- -- (MERGEs on ID, displays result)
--=======================================================================================================
CREATE PROCEDURE [test].[test_080_sp_import_merge_existing_table_from_xl]
AS
BEGIN
DECLARE
   @fn VARCHAR(35) = 'test_080_sp_import_merge_existing_table_from_xl'

   EXEC test.sp_tst_mn_st @fn;
   DROP TABLE IF EXISTS Children;

   CREATE TABLE Children
   (
       id         INT
      ,name	      VARCHAR(50)
      ,height     INT
      ,dob        DATE
      ,hair_len   INT
      ,gender     VARCHAR(255)
      ,section    VARCHAR(15 )
      ,grade      INT
   );

   -- 1 off setup  ??
   EXEC test.hlpr_080_sp_import_merge_existing_table_from_xl
       @tst_num            = '001'
      ,@display_tables     = 1
      ,@inp_file           = 'D:\Dev\CRM\SQL\Tests\080_sp_import_merge_existing_table_from_xl\children.xlsx'
      ,@inp_worksheet      = 'Children'
      ,@inp_range          = 'A1:H70'
      ,@inp_table          = 'Children'
      ,@inp_key_column     = 'id'
      ,@inp_delete_first   = 0
      ,@exp_row_cnt        = 69
      ,@exp_rc             = NULL
      ,@exp_ex_num         = NULL
      ,@exp_ex_msg         = NULL
   ;

   EXEC sp_log 2, @fn, '99: All subtests PASSED'
   EXEC test.sp_tst_mn_cls;
END
/*
EXEC tSQLt.Run 'test.test_080_sp_import_merge_existing_table_from_xl';
EXEC tSQLt.RunAll;
*/