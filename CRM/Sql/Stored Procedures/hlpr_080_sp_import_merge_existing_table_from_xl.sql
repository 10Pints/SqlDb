--=======================================================================================================
-- Author:           Terry Watts
-- Create date:      18-Sep-2025
-- Rtn:              test.hlpr_080_sp_import_merge_existing_table_from_xl
-- Description: test helper for the dbo.sp_import_merge_existing_table_from_xl routine tests 
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
CREATE PROCEDURE [test].[hlpr_080_sp_import_merge_existing_table_from_xl]
    @tst_num                 VARCHAR(50)
   ,@display_tables          BIT
   ,@inp_file                VARCHAR(500)
   ,@inp_worksheet           VARCHAR(15)
   ,@inp_range               VARCHAR(127)
   ,@inp_table               VARCHAR(64)
   ,@inp_key_column          VARCHAR(64)
   ,@inp_delete_first        BIT
   ,@exp_row_cnt             INT             = NULL
   ,@exp_rc                  INT             = NULL
   ,@exp_ex_num              INT             = NULL
   ,@exp_ex_msg              VARCHAR(500)    = NULL
AS
BEGIN
   DECLARE
    @fn                      VARCHAR(35)    = N'hlpr_080_sp_import_merge_existing_table_from_xl'
   ,@error_msg               VARCHAR(1000)
   ,@act_row_cnt             INT            
   ,@act_RC                  INT            
   ,@act_ex_num              INT            
   ,@act_ex_msg              VARCHAR(500)   
   ,@act_RowsInserted_cnt    INT
   ,@act_RowsUpdated_cnt     INT
;

   BEGIN TRY
      EXEC test.sp_tst_hlpr_st @tst_num;

      EXEC sp_log 1, @fn ,' starting
tst_num           :[', @tst_num           ,']
display_tables    :[', @display_tables    ,']
inp_file          :[', @inp_file          ,']
inp_worksheet     :[', @inp_worksheet     ,']
inp_range         :[', @inp_range         ,']
inp_table         :[', @inp_table         ,']
inp_key_column    :[', @inp_key_column    ,']
inp_delete_first  :[', @inp_delete_first  ,']
exp_row_cnt       :[', @exp_row_cnt       ,']
exp_rc            :[', @exp_rc            ,']
exp_RC            :[', @exp_RC            ,']
ex_num            :[', @exp_ex_num        ,']
ex_msg            :[', @exp_ex_msg        ,']
';

      -- SETUP: ??

      WHILE 1 = 1
      BEGIN
         BEGIN TRY
            EXEC sp_log 1, @fn, '010: Calling the tested routine: dbo.sp_import_merge_existing_table_from_xl';
            ------------------------------------------------------------
            EXEC @act_RC = dbo.sp_import_merge_existing_table_from_xl
                @file            = @inp_file
               ,@worksheet       = @inp_worksheet
               ,@range           = @inp_range
               ,@table           = @inp_table
               ,@key_column      = @inp_key_column
               ,@delete_first    = @inp_delete_first
               ,@display_tables  = @display_tables
               ;
  
  EXEC sp_log 1, @fn, '015';
            SELECT
                @act_RowsInserted_cnt = SUM(CASE WHEN ActionType = 'INSERT' THEN 1 ELSE 0 END)
               ,@act_RowsUpdated_cnt  = SUM(CASE WHEN ActionType = 'UPDATE' THEN 1 ELSE 0 END)
            FROM GlobalMergeResults;
            ------------------------------------------------------------
            EXEC sp_log 1, @fn, '020: returned from dbo.sp_import_merge_existing_table_from_xl:
            RowsInserted:', @act_RowsInserted_cnt, '
            RowsUpdated: ', @act_RowsUpdated_cnt,'
            ';

            IF @exp_ex_num IS NOT NULL OR @exp_ex_msg IS NOT NULL
            BEGIN
               EXEC sp_log 4, @fn, '030: oops! Expected exception was not thrown';
               THROW 51000, ' Expected exception was not thrown', 1;
            END
         END TRY
         BEGIN CATCH
            SET @act_ex_num = ERROR_NUMBER();
            SET @act_ex_msg = ERROR_MESSAGE();
            EXEC sp_log 1, @fn, '040: caught  exception: ', @act_ex_num, ' ',      @act_ex_msg;
            EXEC sp_log 1, @fn, '050: check ex num: exp: ', @exp_ex_num, ' act: ', @act_ex_num;

            IF @exp_ex_num IS NULL AND @exp_ex_msg IS NULL
            BEGIN
               EXEC sp_log 4, @fn, '060: an unexpected exception was raised';
               THROW;
            END

            ------------------------------------------------------------
            -- ASSERTION: if here then expected exception
            ------------------------------------------------------------
            IF @exp_ex_num IS NOT NULL EXEC tSQLt.AssertEquals      @exp_ex_num, @act_ex_num, 'ex_num mismatch';
            IF @exp_ex_msg IS NOT NULL EXEC tSQLt.AssertIsSubString @exp_ex_msg, @act_ex_msg, 'ex_msg mismatch';
            
            EXEC sp_log 2, @fn, '070 test# ',@tst_num, ': exception test PASSED;'
            BREAK
         END CATCH

         -- TEST:
         EXEC sp_log 2, @fn, '080: running tests   ';
         IF @exp_row_cnt IS NOT NULL EXEC tSQLt.AssertEquals @exp_row_cnt, @act_RowsInserted_cnt,'81 row_cnt';
         IF @exp_RC      IS NOT NULL EXEC tSQLt.AssertEquals @exp_RC     , @act_RC     ,'100 RC';

         ------------------------------------------------------------
         -- Passed tests
         ------------------------------------------------------------
         BREAK
      END --WHILE

      -- CLEANUP: ??

      EXEC sp_log 1, @fn, '990: all subtests PASSED';
   END TRY
   BEGIN CATCH
      EXEC test.sp_tst_hlpr_hndl_failure;
      THROW;
   END CATCH

   EXEC test.sp_tst_hlpr_hndl_success;
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_080_sp_import_merge_existing_table_from_xl';
*/