--==========================================================================
-- Author:           Terry Watts
-- Create date:      17-Jun-2025
-- Rtn:              test.hlpr_074_sp_infer_field_types
-- Description: test helper for the dbo.sp_infer_field_types routine tests
--
-- Tested rtn description:
-- infers the field types froma staging table
--    based on its data
--
-- EXEC tSQLt.Run 'test.test_<nnn>_<proc_nm>';
-- Design:
-- Tests:
--==========================================================================
CREATE PROCEDURE [test].[hlpr_075_sp_infer_field_types]
    @tst_num         VARCHAR(50)
   ,@display_tables  BIT
   ,@inp_q_table_nm  VARCHAR(100)
   ,@exp_row_cnt     INT             = NULL
   ,@exp_rc          INT             = NULL
   ,@exp_ex_num      INT             = NULL
   ,@exp_ex_msg      VARCHAR(500)    = NULL
AS
BEGIN
   DECLARE
    @fn              VARCHAR(35)    = N'hlpr_075_sp_infer_field_types'
   ,@error_msg       VARCHAR(1000)
   ,@act_row_cnt     INT
   ,@act_RC          INT
   ,@act_ex_num      INT
   ,@act_ex_msg      VARCHAR(500)
   ,@len             INT
   ,@x               BIT

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
            EXEC sp_log 1, @fn, '010: Calling the tested routine: dbo.sp_infer_field_types';
            ------------------------------------------------------------
            EXEC @act_RC = dbo.sp_infer_field_types
                @q_table_nm      = @inp_q_table_nm
               ;

            IF @display_tables = 1
               SELECT * FROM FieldInfo;

            SELECT
                @act_row_cnt = COUNT(*)
               ,@len = MIN([len])
            FROM FieldInfo;
            SET @x = iif(@len>0, 1, 0);
            ------------------------------------------------------------
            EXEC sp_log 1, @fn, '020: returned from dbo.sp_infer_field_types 
row_cnt:', @act_row_cnt, '
minlen:', @len;

            IF @exp_ex_num IS NOT NULL OR @exp_ex_msg IS NOT NULL
            BEGIN
               EXEC sp_log 4, @fn, '030: oops! Expected exception was not thrown';
               THROW 51000, ' Expected exception was not thrown', 1;
            END
         END TRY
         BEGIN CATCH
            SET @act_ex_num = ERROR_NUMBER();
            SET @act_ex_msg = ERROR_MESSAGE();
            EXEC sp_log 1, @fn, '500: caught  exception: ', @act_ex_num, ' ',      @act_ex_msg;
            EXEC sp_log 1, @fn, '510: check ex num: exp: ', @exp_ex_num, ' act: ', @act_ex_num;

            IF @exp_ex_num IS NULL AND @exp_ex_msg IS NULL
            BEGIN
               EXEC sp_log 4, @fn, '520: an unexpected exception was raised';
               THROW;
            END

            ------------------------------------------------------------
            -- ASSERTION: if here then expected exception
            ------------------------------------------------------------
            IF @exp_ex_num IS NOT NULL EXEC tSQLt.AssertEquals      @exp_ex_num, @act_ex_num, 'ex_num mismatch';
            IF @exp_ex_msg IS NOT NULL EXEC tSQLt.AssertIsSubString @exp_ex_msg, @act_ex_msg, 'ex_msg mismatch';

            EXEC sp_log 2, @fn, '590 test# ',@tst_num, ': exception test PASSED;'
            BREAK
         END CATCH

         -- TEST:
         EXEC sp_log 2, @fn, '080: running tests   ';
         EXEC tSQLt.AssertEquals 1, @x, '081: There is a zero length type in teh Field Info';
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
EXEC tSQLt.Run 'test.test_075_sp_infer_field_types';

EXEC tSQLt.RunAll;
*/