--=========================================================================
-- Author:           Terry Watts
-- Create date:      16-Jun-2025
-- Rtn:              test.hlpr_073_fnDeLimitIdentifier
-- Description: test helper for the dbo.fnDeLimitIdentifier routine tests 
--
-- Tested rtn description:
-- delimits identifier  if necessary
-- Design:
-- Tests:
--=========================================================================
CREATE PROCEDURE [test].[hlpr_073_fnDeLimitIdentifier]
    @tst_num          VARCHAR(50)
   ,@inp_q_id         VARCHAR(60)
   ,@exp_out_val      VARCHAR(60)     = NULL
   ,@exp_ex_num       INT             = NULL
   ,@exp_ex_msg       VARCHAR(500)    = NULL
AS
BEGIN
   DECLARE
    @fn                      VARCHAR(35)    = N'hlpr_073_fnDeLimitIdentifier'
   ,@error_msg               VARCHAR(1000)
   ,@act_ex_num              INT            
   ,@act_ex_msg              VARCHAR(500)   
   ,@act_out_val             VARCHAR(60)     = @exp_out_val

   BEGIN TRY
      EXEC test.sp_tst_hlpr_st @tst_num;

      EXEC sp_log 1, @fn ,' starting
tst_num    :[', @tst_num    ,']
inp_q_id   :[', @inp_q_id   ,']
exp_out_val:[', @exp_out_val,']
ex_num     :[', @exp_ex_num ,']
ex_msg     :[', @exp_ex_msg ,']
';

      -- SETUP: ??

      WHILE 1 = 1
      BEGIN
         BEGIN TRY
            EXEC sp_log 1, @fn, '010: Calling the tested routine: dbo.fnDeLimitIdentifier';
            ------------------------------------------------------------

            SET @act_out_val = dbo.fnDeLimitIdentifier
            (
               @inp_q_id
            );

            ------------------------------------------------------------
            EXEC sp_log 1, @fn, '020: returned from dbo.fnDeLimitIdentifier';

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
         --IF @exp_out_val IS NOT NULL 
         EXEC tSQLt.AssertEquals @exp_out_val, @act_out_val,'083 out_val';

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
EXEC tSQLt.Run 'test.test_073_fnDeLimitIdentifier';
*/