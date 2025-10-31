--====================================================================================
-- Author:           Terry Watts
-- Create date:      02-Oct-2025
-- Rtn:              test.hlpr_082_sp_import_propertySalesStaging
-- Description: test helper for the dbo.sp_import_propertySalesStaging routine tests 
--
-- Tested rtn description:
-- Clean imports a spreadsheet into the PropertySalesStaging table
-- Design:      EA:
-- called by:   sp_import_PropertySales
-- Tests:
--
-- Preconditions:
-- Postconditions:
-- POST01: following tables are populated:
--    PropertySalesStaging
--    PropertySales
--    Agency         merge
--    Contacts       merge
--    Delegate       merge
--    Status         merge ??
--
-- POST02: returns the imported row count
--====================================================================================
CREATE PROCEDURE test.hlpr_082_sp_import_propertySalesStaging
    @tst_num                 VARCHAR(50)
   ,@display_tables          BIT
   ,@inp_file                VARCHAR(350)
   ,@inp_worksheet           VARCHAR(32)
   ,@inp_range               VARCHAR(127)
   ,@exp_row_cnt             INT             = NULL
   ,@exp_rc                  INT             = NULL
   ,@exp_ex_num              INT             = NULL
   ,@exp_ex_msg              VARCHAR(500)    = NULL
AS
BEGIN
   DECLARE
    @fn                      VARCHAR(35)    = N'hlpr_082_sp_import_propertySalesStaging'
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
inp_file          :[', @inp_file          ,']
inp_worksheet     :[', @inp_worksheet     ,']
inp_range         :[', @inp_range         ,']
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
            EXEC sp_log 1, @fn, '010: Calling the tested routine: dbo.sp_import_propertySalesStaging';
            ------------------------------------------------------------
            EXEC @act_RC = dbo.sp_import_propertySalesStaging
                @file            = @inp_file
               ,@worksheet       = @inp_worksheet
               ,@range           = @inp_range
               ,@display_tables  = @display_tables
               ;
  
            SELECT @act_row_cnt = COUNT(*) FROM PropertySalesStaging;
            ------------------------------------------------------------
            EXEC sp_log 1, @fn, '020: returned from dbo.sp_import_propertySalesStaging @act_RC: ', @act_RC, ' @act_row_cnt: ', @act_row_cnt;

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
         IF @exp_row_cnt IS NOT NULL EXEC tSQLt.AssertEquals @exp_row_cnt, @act_row_cnt,'093 row_cnt';
         IF @exp_RC      IS NOT NULL EXEC tSQLt.AssertEquals @exp_RC     , @act_RC     ,'094 RC';

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
EXEC tSQLt.Run 'test.test_082_sp_import_propertySalesStaging';
*/