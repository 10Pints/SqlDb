--===================================================================
-- Author:           Terry Watts
-- Create date:      05-Sep-2025
-- Rtn:              test.hlpr_071_sp_drop_table
-- Description: test helper for the dbo.sp_drop_table routine tests 
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
CREATE PROCEDURE test.hlpr_071_sp_drop_table
    @tst_num                 VARCHAR(50)
   ,@display_tables          BIT
   ,@inp_q_table_nm          VARCHAR(40)
   ,@exp_row_cnt             INT             = NULL
   ,@exp_rc                  INT             = NULL
   ,@exp_ex_num              INT             = NULL
   ,@exp_ex_msg              VARCHAR(500)    = NULL
AS
BEGIN
   DECLARE
    @fn                      VARCHAR(35)    = N'hlpr_071_sp_drop_table'
   ,@error_msg               VARCHAR(1000)
   ,@act_row_cnt             INT            
   ,@act_RC                  INT            
   ,@act_ex_num              INT            
   ,@act_ex_msg              VARCHAR(500)   

   BEGIN TRY
      EXEC test.sp_tst_hlpr_st @tst_num;

      EXEC sp_log 1, @fn ,' starting
tst_num           :[', @tst_num           ,']
display_tables    :[', @display_tables    ,']
inp_q_table_nm    :[', @inp_q_table_nm    ,']
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
            EXEC sp_log 1, @fn, '010: Calling the tested routine: dbo.sp_drop_table';
            ------------------------------------------------------------
            EXEC @act_RC = dbo.sp_drop_table
                @q_table_nm      = @inp_q_table_nm
               ;
  
            SELECT @act_row_cnt = @@ROWCOUNT;
            ------------------------------------------------------------
            EXEC sp_log 1, @fn, '020: returned from dbo.sp_drop_table';

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
         IF @exp_row_cnt IS NOT NULL EXEC tSQLt.AssertEquals @exp_row_cnt, @act_row_cnt,'087 row_cnt';
         IF @exp_RC      IS NOT NULL EXEC tSQLt.AssertEquals @exp_RC     , @act_RC     ,'088 RC';

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
EXEC tSQLt.Run 'test.test_071_sp_drop_table';
*/