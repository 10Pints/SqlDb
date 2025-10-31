--==============================================================================
-- Author:           Terry Watts
-- Create date:      12-Sep-2025
-- Description: test helper for the dbo.sp_import_property_sales routine tests 
--
-- Tested rtn description:
--
-- Design:      EA:
-- Tests:
--
-- Preconditions:
-- Postconditions: POST01: following tabnle are populated:
--    PropertySalesStaging
--    PropertySales
--    Agency         merge
--    Contacts       merge
--    Delegate       merge
--    Status         merge ??
--==============================================================================
CREATE PROCEDURE [test].[hlpr_078_sp_import_PropertySales]
    @tst_num               VARCHAR(50)
   ,@display_tables        BIT
   ,@inp_file              VARCHAR(500)
   ,@inp_worksheet         VARCHAR(64)
   ,@inp_range             VARCHAR(255)
   ,@inp_agency_nm         VARCHAR(255)    = NULL
   ,@exp_agency_phone      VARCHAR(255)    = NULL
   ,@exp_row_cnt           INT             = NULL
   ,@exp_agency_cnt        INT             = NULL
   ,@exp_contact_cnt       INT             = NULL
   ,@exp_contactAgency_cnt INT             = NULL
   ,@exp_rc                INT             = NULL
   ,@exp_ex_num            INT             = NULL
   ,@exp_ex_msg            VARCHAR(500)    = NULL
AS
BEGIN
   DECLARE
    @fn                    VARCHAR(35)    = N'hlpr_078_sp_import_PropertySales'
   ,@error_msg             VARCHAR(1000)
   ,@act_row_cnt           INT            
   ,@act_contactAgency_cnt INT             = NULL
   ,@act_agency_cnt        INT             = NULL
   ,@act_contact_cnt       INT             = NULL
   ,@act_RC                INT            
   ,@act_ex_num            INT            
   ,@act_ex_msg            VARCHAR(500)
   ,@act_agency_phone      VARCHAR(250)

   BEGIN TRY
      EXEC test.sp_tst_hlpr_st @tst_num;

      EXEC sp_log 1, @fn ,' starting
tst_num           :[', @tst_num           ,']
display_tables    :[', @display_tables    ,']
inp_file          :[', @inp_file          ,']
@inp_worksheet    :[', @inp_worksheet     ,']
@inp_range        :[', @inp_range         ,']
exp_row_cnt       :[', @exp_row_cnt       ,']
exp_rc            :[', @exp_rc            ,']
exp_RC            :[', @exp_RC            ,']
ex_num            :[', @exp_ex_num        ,']
ex_msg            :[', @exp_ex_msg        ,']
';

      -- SETUP: ??
      DELETE FROM PropertySalesStaging;
      DELETE FROM PropertySales;
      DELETE FROM ContactAgency
      DELETE FROM Agency;
      DELETE FROM Contact;

      WHILE 1 = 1
      BEGIN
         BEGIN TRY
            EXEC sp_log 1, @fn, '010: Calling the tested routine: dbo.sp_import_PropertySales';
            ------------------------------------------------------------
            EXEC @act_RC = dbo.sp_import_PropertySales
                @file      = @inp_file
               ,@worksheet = @inp_worksheet
               ,@range     = @inp_range    
               ;
  
            SELECT @act_row_cnt           = COUNT(*) FROM PropertySalesStaging;
            SELECT @act_agency_cnt        = COUNT(*) FROM Agency;
            SELECT @act_contact_cnt       = COUNT(*) FROM Contact;
            SELECT @act_contactAgency_cnt = COUNT(*) FROM ContactAgency;
            ------------------------------------------------------------
            EXEC sp_log 1, @fn, '020: returned from dbo.sp_import_PropertySales:
@act_row_cnt:           [', @act_row_cnt           ,']
@act_agency_cnt:        [', @act_agency_cnt        ,']
@act_contact_cnt:       [', @act_contact_cnt       ,']
@act_contactAgency_cnt: [', @act_contactAgency_cnt ,']
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
         IF @exp_row_cnt            IS NOT NULL EXEC tSQLt.AssertEquals @exp_row_cnt          , @act_row_cnt          ,'081 row_cnt';
         IF @exp_agency_cnt         IS NOT NULL EXEC tSQLt.AssertEquals @exp_agency_cnt       , @act_agency_cnt       ,'082 agency_cnt';
         IF @exp_contact_cnt        IS NOT NULL EXEC tSQLt.AssertEquals @exp_contact_cnt      , @act_contact_cnt      ,'083 contact_cnt';
         IF @exp_contactAgency_cnt  IS NOT NULL EXEC tSQLt.AssertEquals @exp_contactAgency_cnt, @act_contactAgency_cnt,'084 contactAgency_cnt';
         IF @exp_RC                 IS NOT NULL EXEC tSQLt.AssertEquals @exp_RC               , @act_RC               ,'085 RC';

         -- Agency phone;
         IF @inp_agency_nm IS NOT NULL
         BEGIN
            SELECT @act_agency_phone = phone from Agency where agency_nm = @inp_agency_nm;
            EXEC tSQLt.AssertEquals @exp_agency_phone      , @act_agency_phone      ,'086 agency_phone';
         END

         -- ContactAgency
         -- Contact;

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
EXEC tSQLt.Run 'test.test_078_sp_import_PropertySales';

EXEC tSQLt.RunAll;
*/