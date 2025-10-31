--==============================================================================
-- Author:           Terry Watts
-- Create date:      22-Oct-2025
-- Rtn:              test.hlpr_088_sp_pop_AgencyStaging_tbl
-- Description: test helper for the dbo.sp_pop_AgencyStaging_tbl routine tests
--
-- Tested rtn description:
-- Populates the AgencyStaging table from PropertySalesStaging
-- Returns      the merge count
-- Design:
-- Tests:
-- Preconditions:
--    PRE01: PropertySalesStaging popd
--
-- Postconditions:
--    POST01: AgencyStaging popd
--    POST02: Returns the merge count
--==============================================================================
CREATE PROCEDURE [test].[hlpr_088_sp_pop_AgencyStaging_tbl]
    @tst_num                  VARCHAR(50)
   ,@display_tables           BIT
   ,@exp_row_cnt              INT            = NULL
   ,@tst_agency_nm            VARCHAR(500)   = NULL -- key
   ,@exp_delegate_nm          VARCHAR(10)    = NULL
   ,@exp_phone                VARCHAR(250)   = NULL
   ,@exp_viber                VARCHAR(50)    = NULL
   ,@exp_whatsApp             VARCHAR(50)    = NULL
   ,@exp_facebook             VARCHAR(100)   = NULL
   ,@exp_messenger            VARCHAR(100)   = NULL
   ,@exp_website              VARCHAR(255)   = NULL
   ,@exp_email                VARCHAR(255)   = NULL
   ,@exp_primary_contact_nm   VARCHAR(50)    = NULL
   ,@exp_address              VARCHAR(250)   = NULL
   ,@exp_notes_2              VARCHAR(50)    = NULL
   ,@exp_age                  VARCHAR(50)    = NULL
   ,@exp_Actions_08_OCT       VARCHAR(50)    = NULL
   ,@exp_jan_16_2025          VARCHAR(50)    = NULL
   ,@exp_Action_by_dt         VARCHAR(50)    = NULL
   ,@exp_replied              VARCHAR(50)    = NULL
   ,@exp_history              VARCHAR(50)    = NULL
   ,@exp_ex_num               INT            = NULL
   ,@exp_ex_msg               VARCHAR(500)   = NULL
AS
BEGIN
   DECLARE
    @fn                       VARCHAR(35)    = N'hlpr_088_sp_pop_AgencyStaging_tbl'
   ,@error_msg                VARCHAR(1000)  = NULL
   ,@act_row_cnt              INT            = NULL
   ,@act_delegate_nm          VARCHAR(10)    = NULL
   ,@act_phone                VARCHAR(250)   = NULL
   ,@act_viber                VARCHAR(50)    = NULL
   ,@act_whatsApp             VARCHAR(50)    = NULL
   ,@act_facebook             VARCHAR(100)   = NULL
   ,@act_messenger            VARCHAR(100)   = NULL
   ,@act_website              VARCHAR(255)   = NULL
   ,@act_email                VARCHAR(255)   = NULL
   ,@act_primary_contact_nm   VARCHAR(50)    = NULL
   ,@act_address              VARCHAR(250)   = NULL
   ,@act_notes_2              VARCHAR(50)    = NULL
   ,@act_age                  VARCHAR(50)    = NULL
   ,@act_Actions_08_OCT       VARCHAR(50)    = NULL
   ,@act_jan_16_2025          VARCHAR(50)    = NULL
   ,@act_Action_by_dt         VARCHAR(50)    = NULL
   ,@act_replied              VARCHAR(50)    = NULL
   ,@act_history              VARCHAR(50)    = NULL
   ,@act_ex_num               INT
   ,@act_ex_msg               VARCHAR(500)

   BEGIN TRY
      EXEC test.sp_tst_hlpr_st @tst_num;

      EXEC sp_log 1, @fn ,' starting
tst_num               :[', @tst_num                ,']
display_tables        :[', @display_tables         ,']
exp_row_cnt           :[', @exp_row_cnt            ,']
tst_agency_nm         :[', @tst_agency_nm          ,']
exp_delegate_nm       :[', @exp_delegate_nm        ,']
exp_phone             :[', @exp_phone              ,']
exp_viber             :[', @exp_viber              ,']
exp_whatsApp          :[', @exp_whatsApp           ,']
exp_facebook          :[', @exp_facebook           ,']
exp_messenger         :[', @exp_messenger          ,']
exp_website           :[', @exp_website            ,']
exp_email             :[', @exp_email              ,']
exp_primary_contact_nm:[', @exp_primary_contact_nm ,']
exp_address           :[', @exp_address            ,']
exp_notes_2           :[', @exp_notes_2            ,']
exp_age               :[', @exp_age                ,']
exp_Actions_08_OCT    :[', @exp_Actions_08_OCT     ,']
exp_jan_16_2025       :[', @exp_jan_16_2025        ,']
exp_Action_by_dt      :[', @exp_Action_by_dt       ,']
exp_replied           :[', @exp_replied            ,']
exp_history           :[', @exp_history            ,']
ex_num                :[', @exp_ex_num             ,']
ex_msg                :[', @exp_ex_msg             ,']
';

      -- SETUP: ??

      WHILE 1 = 1
      BEGIN
         BEGIN TRY
            EXEC sp_log 1, @fn, '010: Calling the tested routine: dbo.sp_pop_AgencyStaging_tbl';
            ------------------------------------------------------------
            EXEC @act_row_cnt = dbo.sp_pop_AgencyStaging_tbl
                @display_tables  = @display_tables
               ;

            IF @tst_agency_nm IS NOT NULL -- key
               SELECT 
                @act_delegate_nm        = delegate_nm       
               ,@act_phone              = phone             
               ,@act_viber              = viber             
               ,@act_whatsApp           = whatsApp          
               ,@act_facebook           = facebook          
               ,@act_messenger          = messenger         
               ,@act_website            = website           
               ,@act_email              = email             
               ,@act_primary_contact_nm = primary_contact_nm
               ,@act_address            = [address]           
               ,@act_notes_2            = notes_2       
               ,@act_age                = age           
               ,@act_Actions_08_OCT     = actions_08_OCT
               ,@act_jan_16_2025        = jan_16_2025   
               ,@act_Action_by_dt       = Action_by_dt  
               ,@act_replied            = replied       
               ,@act_history            = history       
               FROM AgencyStaging
               WHERE agency_nm = @tst_agency_nm;

      EXEC sp_log 1, @fn ,'020: dbo.sp_pop_AgencyStaging_tbl returned:
act_row_cnt           :[', @act_row_cnt            ,']
tst_agency_nm         :[', @tst_agency_nm          ,']
act_delegate_nm       :[', @act_delegate_nm        ,']
act_phone             :[', @act_phone              ,']
act_viber             :[', @act_viber              ,']
act_whatsApp          :[', @act_whatsApp           ,']
act_facebook          :[', @act_facebook           ,']
act_messenger         :[', @act_messenger          ,']
act_website           :[', @act_website            ,']
act_email             :[', @act_email              ,']
act_primary_contact_nm:[', @act_primary_contact_nm ,']
act_address           :[', @act_address            ,']
act_notes_2           :[', @act_notes_2            ,']
act_age               :[', @act_age                ,']
act_Actions_08_OCT    :[', @act_Actions_08_OCT     ,']
act_jan_16_2025       :[', @act_jan_16_2025        ,']
act_Action_by_dt      :[', @act_Action_by_dt       ,']
act_replied           :[', @act_replied            ,']
act_history           :[', @act_history            ,']
';  
            ------------------------------------------------------------
            EXEC sp_log 1, @fn, '020: returned from dbo.sp_pop_AgencyStaging_tbl';

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
         IF @exp_row_cnt IS NOT NULL EXEC tSQLt.AssertEquals @exp_row_cnt, @act_row_cnt,'081 row_cnt';
         IF @tst_agency_nm IS NOT NULL  -- key
         BEGIN
            IF @exp_delegate_nm        IS NOT NULL EXEC tSQLt.AssertEquals @exp_delegate_nm       , @act_delegate_nm       ,'082 delegate_nm';
            IF @exp_phone              IS NOT NULL EXEC tSQLt.AssertEquals @exp_phone             , @act_phone             ,'084 phone';
            IF @exp_viber              IS NOT NULL EXEC tSQLt.AssertEquals @exp_viber             , @act_viber             ,'085 viber';
            IF @exp_whatsApp           IS NOT NULL EXEC tSQLt.AssertEquals @exp_whatsApp          , @act_whatsApp          ,'086 whatsApp';
            IF @exp_facebook           IS NOT NULL EXEC tSQLt.AssertEquals @exp_facebook          , @act_facebook          ,'087 facebook';
            IF @exp_messenger          IS NOT NULL EXEC tSQLt.AssertEquals @exp_messenger         , @act_messenger         ,'088 messenger';
            IF @exp_website            IS NOT NULL EXEC tSQLt.AssertEquals @exp_website           , @act_website           ,'089 website';
            IF @exp_email              IS NOT NULL EXEC tSQLt.AssertEquals @exp_email             , @act_email             ,'090 email';
            IF @exp_primary_contact_nm IS NOT NULL EXEC tSQLt.AssertEquals @exp_primary_contact_nm, @act_primary_contact_nm,'091 primary_con';
            IF @exp_address            IS NOT NULL EXEC tSQLt.AssertEquals @exp_address           , @act_address           ,'092 address';
            IF @exp_notes_2            IS NOT NULL EXEC tSQLt.AssertEquals @exp_notes_2           , @act_notes_2           ,'093 notes_2';
            IF @exp_age                IS NOT NULL EXEC tSQLt.AssertEquals @exp_age               , @act_age               ,'094 age';
            IF @exp_Actions_08_OCT     IS NOT NULL EXEC tSQLt.AssertEquals @exp_Actions_08_OCT    , @act_Actions_08_OCT    ,'095 Actions_08_OCT';
            IF @exp_jan_16_2025        IS NOT NULL EXEC tSQLt.AssertEquals @exp_jan_16_2025       , @act_jan_16_2025       ,'096 jan_16_2025';
            IF @exp_Action_by_dt       IS NOT NULL EXEC tSQLt.AssertEquals @exp_Action_by_dt      , @act_Action_by_dt      ,'097 Action_by_dt';
            IF @exp_replied            IS NOT NULL EXEC tSQLt.AssertEquals @exp_replied           , @act_replied           ,'098 replied';
            IF @exp_history            IS NOT NULL EXEC tSQLt.AssertEquals @exp_history           , @act_history           ,'098 history';
         END -- if @tst_agency_nm IS NOT NULL  -- key
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
EXEC tSQLt.Run 'test.test_088_sp_pop_AgencyStaging_tbl';

select * from PropertySalesStaging;
NULL
*/