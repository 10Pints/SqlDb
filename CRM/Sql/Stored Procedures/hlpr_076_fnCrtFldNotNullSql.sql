-- =======================================================================
-- Author:           Terry Watts
-- Create date:      17-Jun-2025
-- Rtn:              test.hlpr_075_fnCrtFldNotNullSql
-- Description: test helper for the dbo.fnCrtFldNotNullSql routine tests
--
-- Tested rtn description:
--
-- =======================================================================
CREATE PROCEDURE [test].[hlpr_076_fnCrtFldNotNullSql]
    @tst_num        VARCHAR(50)
   ,@inp_q_table_nm VARCHAR(60)
   ,@inp_fld_nm     VARCHAR(40)
   ,@inp_ty         VARCHAR(15)
   ,@exp_sql        VARCHAR(4000)   = NULL
   ,@exp_ex_num     INT             = NULL
   ,@exp_ex_msg     VARCHAR(500)    = NULL
AS
BEGIN
   DECLARE
    @fn             VARCHAR(35)    = N'hlpr_076_fnCrtFldNotNullSql'
   ,@error_msg      VARCHAR(1000)
   ,@act_ex_num     INT
   ,@act_ex_msg     VARCHAR(500)
   ,@act_sql        VARCHAR(4000)   = @exp_sql

   BEGIN TRY
      EXEC test.sp_tst_hlpr_st @tst_num;

      EXEC sp_log 1, @fn ,' starting
tst_num       :[', @tst_num       ,']
inp_q_table_nm:[', @inp_q_table_nm,']
inp_fld_nm    :[', @inp_fld_nm    ,']
inp_ty        :[', @inp_ty        ,']
exp_sql       :[', @exp_sql       ,']
ex_num        :[', @exp_ex_num    ,']
ex_msg        :[', @exp_ex_msg    ,']
';

      -- SETUP: ??

      WHILE 1 = 1
      BEGIN
         BEGIN TRY
            EXEC sp_log 1, @fn, '010: Calling the tested routine: dbo.fnCrtFldNotNullSql';
            ------------------------------------------------------------

            SET @act_sql = dbo.fnCrtFldNotNullSql
            (
               @inp_q_table_nm, @inp_fld_nm, @inp_ty
            );

            ------------------------------------------------------------
            EXEC sp_log 1, @fn, '020: returned from dbo.fnCrtFldNotNullSql
@act_sql:
',@act_sql

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
         IF @exp_sql IS NOT NULL EXEC tSQLt.AssertEquals @exp_sql, @act_sql,'083 sql';

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
EXEC tSQLt.Run 'test.test_076_fnCrtFldNotNullSql';
*/