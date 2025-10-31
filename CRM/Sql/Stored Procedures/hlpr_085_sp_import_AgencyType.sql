--==========================================================================
-- Author:           Terry Watts
-- Create date:      03-Oct-2025
-- Rtn:              test.hlpr_085_sp_import_AgencyType
-- Description: test helper for the dbo.sp_import_AgencyType routine tests 
--
-- Tested rtn description:
-- Imports the AgencyType table from an XL sheet
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
--==========================================================================
CREATE PROCEDURE test.hlpr_085_sp_import_AgencyType
    @tst_num                 VARCHAR(50)
   ,@display_tables          BIT
   ,@inp_file                VARCHAR(500)
   ,@inp_worksheet           VARCHAR(32)
   ,@inp_range               VARCHAR(127)
   ,@exp_row_cnt             INT             = NULL
   ,@exp_first_id            INT             = NULL
   ,@exp_first_nm            VARCHAR(50)     = NULL
   ,@exp_last_id             INT             = NULL
   ,@exp_last_nm             VARCHAR(50)     = NULL
   ,@exp_ex_num              INT             = NULL
   ,@exp_ex_msg              VARCHAR(500)    = NULL
AS
BEGIN
   DECLARE
    @fn                      VARCHAR(35)    = N'hlpr_085_sp_import_AgencyType'
   ,@error_msg               VARCHAR(1000)
   ,@act_row_cnt             INT            
   ,@act_ex_num              INT            
   ,@act_ex_msg              VARCHAR(500)   
   ,@act_first_id            INT             = NULL
   ,@act_first_nm            VARCHAR(50)     = NULL
   ,@act_last_id             INT             = NULL
   ,@act_last_nm             VARCHAR(50)     = NULL

   BEGIN TRY
      EXEC test.sp_tst_hlpr_st @tst_num;

      EXEC sp_log 1, @fn ,' starting
tst_num           :[', @tst_num           ,']
display_tables    :[', @display_tables    ,']
inp_file          :[', @inp_file          ,']
inp_worksheet     :[', @inp_worksheet     ,']
inp_range         :[', @inp_range         ,']
exp_row_cnt       :[', @exp_row_cnt       ,']
ex_num            :[', @exp_ex_num        ,']
ex_msg            :[', @exp_ex_msg        ,']
';

      -- SETUP: ??

      WHILE 1 = 1
      BEGIN
         BEGIN TRY
            EXEC sp_log 1, @fn, '010: Calling the tested routine: dbo.sp_import_AgencyType';
            ------------------------------------------------------------
            EXEC @act_row_cnt = dbo.sp_import_AgencyType
                @file            = @inp_file
               ,@worksheet       = @inp_worksheet
               ,@range           = @inp_range
               ,@display_tables  = @display_tables
               ;
  
            SELECT TOP 1
                @act_first_id   = agencyType_id
               ,@act_first_nm   = agencyType_nm
            FROM AgencyType;

            SELECT TOP 1 
                @act_last_id    = agencyType_id
               ,@act_last_nm    = agencyType_nm
            FROM
            (
               SELECT TOP 1000 agencyType_id, agencyType_nm
               FROM AgencyType
               ORDER BY agencyType_id DESC
            ) X;

            ------------------------------------------------------------
            EXEC sp_log 1, @fn, '020: returned from dbo.sp_import_AgencyType';

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
         IF @exp_row_cnt  IS NOT NULL EXEC tSQLt.AssertEquals @exp_row_cnt,  @act_row_cnt, '081 row_cnt';
         IF @exp_first_id IS NOT NULL EXEC tSQLt.AssertEquals @exp_first_id, @act_first_id,'082 first_id';
         IF @exp_first_nm IS NOT NULL EXEC tSQLt.AssertEquals @exp_first_nm, @act_first_nm,'083 first_nm';
         IF @exp_last_id  IS NOT NULL EXEC tSQLt.AssertEquals @exp_last_id,  @act_last_id ,'084 last_id';
         IF @exp_last_nm  IS NOT NULL EXEC tSQLt.AssertEquals @exp_last_nm,  @act_last_nm ,'085 rlast_nm';

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
EXEC tSQLt.Run 'test.test_085_sp_import_AgencyType';
*/