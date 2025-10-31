--===================================================================
-- Author:           Terry Watts
-- Create date:      05-Sep-2025
-- Rtn:              test.test_071_sp_drop_table
-- Description: main test routine for the dbo.sp_drop_table routine 
--
-- Tested rtn description:
-- Drops a table if it exists
-- Design:
-- Tests:
--
-- PRECONDITIONS:
-- PRE 01 @tbl_nm must be specified NOT NULL or EMPTY Checked
--
-- POSTCONDITIONS:
-- POST01: table does not exist
--===================================================================
CREATE PROCEDURE test.test_071_sp_drop_table
AS
BEGIN
DECLARE
    @fn VARCHAR(35) = 'test_071_sp_drop_table'
   ,@tst VARCHAR(10)
   ,@tbl VARCHAR(10)
   ;

   EXEC test.sp_tst_mn_st @fn;

   CREATE TABLE test.test_071_1
   (
      id INT
   );

   BEGIN TRY
      -- 1 off setup  ??
      SET @tst = '001';
      SET @tbl = NULL;
      EXEC test.hlpr_071_sp_drop_table
          @tst_num            = @tst
         ,@display_tables     = 0
         ,@inp_q_table_nm     = @tbl
         ,@exp_row_cnt        = NULL
         ,@exp_rc             = NULL
         ,@exp_ex_num         = 50005
         ,@exp_ex_msg         = '@q_table_nm must be specified'
      ;

      SET @tst = '002';
      SET @tbl = '';
      EXEC test.hlpr_071_sp_drop_table
          @tst_num            = @tst
         ,@display_tables     = 0
         ,@inp_q_table_nm     = @tbl
         ,@exp_row_cnt        = NULL
         ,@exp_rc             = NULL
         ,@exp_ex_num         = 50005
         ,@exp_ex_msg         = '@q_table_nm must be specified'
      ;

      SET @tst = '003';
      SET @tbl = 'test.test_071_1';
      EXEC test.hlpr_071_sp_drop_table
          @tst_num            = @tst
         ,@display_tables     = 0
         ,@inp_q_table_nm     = @tbl
         ,@exp_row_cnt        = NULL
         ,@exp_rc             = NULL
         ,@exp_ex_num         = NULL
         ,@exp_ex_msg         = NULL
      ;
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn, '500: caught exception test: ' ,@tst;
      EXEC sp_drop_table @tbl;
      THROW;
   END CATCH

   EXEC sp_log 2, @fn, '99: All subtests PASSED'
   EXEC test.sp_tst_mn_cls;
END
/*
EXEC tSQLt.Run 'test.test_071_sp_drop_table';

EXEC tSQLt.RunAll;
*/