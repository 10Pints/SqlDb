--==========================================================================
-- Author:           Terry Watts
-- Create date:      02-Oct-2025
-- Rtn:              test.hlpr_083_sp_merge_contact_tbl
-- Description: test helper for the dbo.sp_merge_contact_tbl routine tests 
--
-- Tested rtn description:
-- Merges the Delegate table from PropertySalesStaging
-- Returns      the merge count
-- Design:
-- Tests:
--==========================================================================
CREATE PROCEDURE test.hlpr_083_sp_merge_contact_tbl
    @tst_num                         VARCHAR(50)
   ,@display_tables                  BIT
   ,@exp_row_cnt                     INT             = NULL
   ,@exp_contact_id                  INT             = NULL
   ,@exp_contact_nm                  VARCHAR(50)     = NULL
   ,@exp_role                        VARCHAR(50)     = NULL
   ,@exp_phone                       VARCHAR(50)     = NULL
   ,@exp_viber                       VARCHAR(50)     = NULL
   ,@exp_whatsapp                    VARCHAR(50)     = NULL
   ,@exp_facebook                    VARCHAR(50)     = NULL
   ,@exp_messenger                   VARCHAR(50)     = NULL
   ,@exp_primary_contact_type        VARCHAR(50)     = NULL
   ,@exp_primary_contact_detail      VARCHAR(50)     = NULL
   ,@exp_last_contacted              DATE            = NULL
   ,@exp_is_active                   BIT             = NULL
   ,@exp_sex                         CHAR(1)         = NULL
   ,@exp_age                         INT             = NULL
   ,@exp_ex_num                      INT             = NULL
   ,@exp_ex_msg                      VARCHAR(500)    = NULL
AS
BEGIN
   DECLARE
    @fn                              VARCHAR(35)    = N'hlpr_083_sp_merge_contact_tbl'
   ,@error_msg                       VARCHAR(1000)
   ,@act_row_cnt                     INT            
   ,@act_contact_id                  INT            
   ,@act_contact_nm                  VARCHAR(50)    
   ,@act_role                        VARCHAR(50)    
   ,@act_phone                       VARCHAR(50)    
   ,@act_viber                       VARCHAR(50)    
   ,@act_whatsApp                    VARCHAR(50)    
   ,@act_facebook                    VARCHAR(50)    
   ,@act_messenger                   VARCHAR(50)    
   ,@act_primary_contact_type        VARCHAR(50)    
   ,@act_primary_contact_detail      VARCHAR(50)    
   ,@act_last_contacted              DATE           
   ,@act_is_active                   BIT            
   ,@act_sex                         CHAR(1)        
   ,@act_age                         INT            
   ,@act_ex_num                      INT            
   ,@act_ex_msg                      VARCHAR(500)   

   BEGIN TRY
      EXEC test.sp_tst_hlpr_st @tst_num;

      EXEC sp_log 1, @fn ,' starting
tst_num                   :[', @tst_num                   ,']
display_tables            :[', @display_tables            ,']
exp_row_cnt               :[', @exp_row_cnt               ,']
exp_contact_id            :[', @exp_contact_id            ,']
exp_contact_nm            :[', @exp_contact_nm            ,']
exp_role                  :[', @exp_role                  ,']
exp_phone                 :[', @exp_phone                 ,']
exp_viber                 :[', @exp_viber                 ,']
exp_whatsapp              :[', @exp_whatsapp              ,']
exp_facebook              :[', @exp_facebook              ,']
exp_messenger             :[', @exp_messenger             ,']
exp_primary_contact_type  :[', @exp_primary_contact_type  ,']
exp_primary_contact_detail:[', @exp_primary_contact_detail,']
exp_last_contacted        :[', @exp_last_contacted        ,']
exp_is_active             :[', @exp_is_active             ,']
exp_sex                   :[', @exp_sex                   ,']
exp_age                   :[', @exp_age                   ,']
ex_num                    :[', @exp_ex_num                ,']
ex_msg                    :[', @exp_ex_msg                ,']
';

      -- SETUP: ??

      WHILE 1 = 1
      BEGIN
         BEGIN TRY
            EXEC sp_log 1, @fn, '010: Calling the tested routine: dbo.sp_merge_contact_tbl';
            ------------------------------------------------------------
            EXEC @act_row_cnt = dbo.sp_merge_contact_tbl
                @display_tables          = @display_tables
               ;
  
            ------------------------------------------------------------
            EXEC sp_log 1, @fn, '020: returned from dbo.sp_merge_contact_tbl';

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
         IF @exp_row_cnt                IS NOT NULL EXEC tSQLt.AssertEquals @exp_row_cnt               , @act_row_cnt               ,'087 row_cnt';
         IF @exp_contact_id             IS NOT NULL EXEC tSQLt.AssertEquals @exp_contact_id            , @act_contact_id            ,'089 contact_id';
         IF @exp_contact_nm             IS NOT NULL EXEC tSQLt.AssertEquals @exp_contact_nm            , @act_contact_nm            ,'090 contact_nm';
         IF @exp_role                   IS NOT NULL EXEC tSQLt.AssertEquals @exp_role                  , @act_role                  ,'091 role';
         IF @exp_phone                  IS NOT NULL EXEC tSQLt.AssertEquals @exp_phone                 , @act_phone                 ,'092 phone';
         IF @exp_viber                  IS NOT NULL EXEC tSQLt.AssertEquals @exp_viber                 , @act_viber                 ,'093 viber';
         IF @exp_whatsApp               IS NOT NULL EXEC tSQLt.AssertEquals @exp_whatsApp              , @act_whatsApp              ,'094 whatsApp';
         IF @exp_facebook               IS NOT NULL EXEC tSQLt.AssertEquals @exp_facebook              , @act_facebook              ,'095 facebook';
         IF @exp_messenger              IS NOT NULL EXEC tSQLt.AssertEquals @exp_messenger             , @act_messenger             ,'096 messenger';
         IF @exp_primary_contact_type   IS NOT NULL EXEC tSQLt.AssertEquals @exp_primary_contact_type  , @act_primary_contact_type  ,'097 primary_contact_type';
         IF @exp_primary_contact_detail IS NOT NULL EXEC tSQLt.AssertEquals @exp_primary_contact_detail, @act_primary_contact_detail,'098 primary_contact_detail';
         IF @exp_last_contacted         IS NOT NULL EXEC tSQLt.AssertEquals @exp_last_contacted        , @act_last_contacted        ,'099 last_contacted';
         IF @exp_is_active              IS NOT NULL EXEC tSQLt.AssertEquals @exp_is_active             , @act_is_active             ,'100 is_active';
         IF @exp_sex                    IS NOT NULL EXEC tSQLt.AssertEquals @exp_sex                   , @act_sex                   ,'101 sex';
         IF @exp_age                    IS NOT NULL EXEC tSQLt.AssertEquals @exp_age                   , @act_age                   ,'102 age';

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
EXEC tSQLt.Run 'test.test_083_sp_merge_contact_tbl';
*/