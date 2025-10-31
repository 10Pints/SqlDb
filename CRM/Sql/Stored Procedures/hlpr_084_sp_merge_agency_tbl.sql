--=========================================================================
-- Author:           Terry Watts
-- Create date:      02-Oct-2025
-- Rtn:              test.hlpr_084_sp_merge_agency_tbl
-- Description: test helper for the dbo.sp_merge_agency_tbl routine tests
--
-- Tested rtn description:
-- Merges the Agency table from PropertySalesStaging
-- Returns      the merge count
-- Design:
-- Tests:
--=========================================================================
CREATE PROCEDURE [test].[hlpr_084_sp_merge_agency_tbl]
    @tst_num                        VARCHAR(50)
   ,@display_tables                 BIT            = 1
   ,@exp_row_cnt                    INT            = NULL
   ,@exp_ex_num                     INT            = NULL
   ,@exp_ex_msg                     VARCHAR(500)   = NULL

   -- row tests
   ,@tst_agency_nm                  VARCHAR(50)    = NULL -- search key
   ,@exp_agency_type_nm             VARCHAR(15)    = NULL
   ,@exp_area                       VARCHAR(15)    = NULL
   ,@exp_delegate_nm                VARCHAR(50)    = NULL
   ,@exp_status                     VARCHAR(15)    = NULl
   ,@exp_first_reg                  DATE           = NULL
   ,@exp_notes                      VARCHAR(250)   = NULL
   ,@exp_quality                    INT
   ,@exp_primary_contact_nm         VARCHAR(50)    = NULL
   ,@exp_role                       VARCHAR(50)    = NULL
   ,@exp_phone                      VARCHAR(50)    = NULL
   ,@exp_facebook                   VARCHAR(50)    = NULL
   ,@exp_messenger                  VARCHAR(50)    = NULL
   ,@exp_preferred_contact_method   VARCHAR(50)    = NULL
   ,@exp_email                      VARCHAR(50)    = NULL
   ,@exp_WhatsApp                   VARCHAR(50)    = NULL
   ,@exp_viber                      VARCHAR(50)    = NULL
   ,@exp_website                    VARCHAR(50)    = NULL
   ,@exp_Address                    VARCHAR(50)    = NULL
   ,@exp_Notes_2                    VARCHAR(50)    = NULL
   ,@exp_Old_Notes                  VARCHAR(50)    = NULL
   ,@exp_age                        VARCHAR(50)    = NULL
   ,@exp_Actions_08_OCT             VARCHAR(50)    = NULL
   ,@exp_Jan_16_2025                VARCHAR(50)    = NULL
   ,@exp_Action_By_dt               VARCHAR(50)    = NULL
   ,@exp_Replied                    VARCHAR(50)    = NULL
   ,@exp_History                    VARCHAR(500)    = NULL
AS
BEGIN
   DECLARE
    @fn                             VARCHAR(35)    = N'hlpr_084_sp_merge_agency_tbl'
   ,@error_msg                      VARCHAR(1000)
   ,@act_row_cnt                    INT
   ,@act_ex_num                     INT
   ,@act_ex_msg                     VARCHAR(500)
   ,@act_agency_type_nm             VARCHAR(15)    = NULL
   ,@act_area                       VARCHAR(15)    = NULL
   ,@act_delegate_nm                VARCHAR(50)    = NULL
   ,@act_status                     VARCHAR(15)    = NULL
   ,@act_first_reg                  DATE           = NULL
   ,@act_quality                    INT
   ,@act_notes                      VARCHAR(250)   = NULL
   ,@act_delegate_id                INT            = NULL
   ,@act_primary_contact_nm         VARCHAR(50)    = NULL
   ,@act_primary_contact_id         INT            = NULL
   ,@act_role                       VARCHAR(50)    = NULL
   ,@act_sex                        VARCHAR(5)     = NULL
   ,@act_phone                      VARCHAR(50)    = NULL
   ,@act_facebook                   VARCHAR(50)    = NULL
   ,@act_messenger                  VARCHAR(50)    = NULL
   ,@act_preferred_contact_method   VARCHAR(50)    = NULL
   ,@act_email                      VARCHAR(50)    = NULL
   ,@act_WhatsApp                   VARCHAR(50)    = NULL
   ,@act_viber                      VARCHAR(50)    = NULL
   ,@act_website                    VARCHAR(50)    = NULL
   ,@act_Address                    VARCHAR(50)    = NULL
   ,@act_Notes_2                    VARCHAR(50)    = NULL
   ,@act_Old_Notes                  VARCHAR(50)    = NULL
   ,@act_age                        VARCHAR(50)    = NULL
   ,@act_Actions_08_OCT             VARCHAR(50)    = NULL
   ,@act_Jan_16_2025                VARCHAR(50)    = NULL
   ,@act_Action_By_dt               VARCHAR(50)    = NULL
   ,@act_Replied                    VARCHAR(50)    = NULL
   ,@act_History                    VARCHAR(500)    = NULL

   BEGIN TRY
      EXEC test.sp_tst_hlpr_st @tst_num;

      EXEC sp_log 1, @fn ,' starting
tst_num           :[', @tst_num           ,']
display_tables    :[', @display_tables    ,']
exp_row_cnt       :[', @exp_row_cnt       ,']
ex_num            :[', @exp_ex_num        ,']
ex_msg            :[', @exp_ex_msg        ,']
';

      -- SETUP: ??

      WHILE 1 = 1
      BEGIN
         BEGIN TRY
            EXEC sp_log 1, @fn, '010: Calling the tested routine: dbo.sp_merge_agency_tbl';
            ------------------------------------------------------------
            EXEC @act_row_cnt = dbo.sp_merge_agency_tbl
                @display_tables  = @display_tables
               ;

            ------------------------------------------------------------
            EXEC sp_log 1, @fn, '020: returned from dbo.sp_merge_agency_tbl';

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

            EXEC sp_log 2, @fn, '530 test# ',@tst_num, ': exception test PASSED;'
            BREAK
         END CATCH

         -- TEST:
         EXEC sp_log 2, @fn, '080: running tests   ';
         IF @exp_row_cnt IS NOT NULL EXEC tSQLt.AssertEquals @exp_row_cnt, @act_row_cnt,'087 row_cnt';

         IF @tst_agency_nm IS NOT NULL
         BEGIN
            SELECT
                @act_agency_type_nm          = agencyType_nm
               ,@act_area                    = area_nm
               ,@act_delegate_id             = delegate_id
               ,@act_status                  = status_nm
               ,@act_notes                   = notes
               ,@act_quality                 = quality
               ,@act_first_reg               = first_reg
               ,@act_primary_contact_id      = primary_contact_id
               ,@act_phone                   = phone
               ,@act_messenger               = messenger
               ,@act_preferred_contact_method= preferred_contact_method
               ,@act_email                   = email
               ,@act_WhatsApp                = WhatsApp
               ,@act_viber                   = viber
               ,@act_website                 = website
               ,@act_Address                 = [Address]
               ,@act_primary_contact_id      = primary_contact_id
               ,@act_primary_contact_nm      = primary_contact_nm
               ,@act_primary_contact_id      = primary_contact_id
               ,@act_role                    = [role]
               ,@act_sex                     = sex
               ,@act_age                     = age
               ,@act_Actions_08_OCT          = actions_08_OCT
               ,@act_Jan_16_2025             = Jan_16_2025
               ,@act_Action_By_dt            = Action_By_dt
               ,@act_Replied                 = Replied
               ,@act_History                 = History
            FROM Agency_vw
            WHERE agency_nm = @tst_agency_nm
            ;

            IF @exp_agency_type_nm           IS NOT NULL EXEC tSQLt.AssertEquals      @exp_agency_type_nm          , @act_agency_type_nm          , '088 agency_type_nm mismatch';
            IF @exp_area                     IS NOT NULL EXEC tSQLt.AssertEquals      @exp_area                    , @act_area                    , '089 area mismatch';
            IF @exp_delegate_nm              IS NOT NULL EXEC tSQLt.AssertEquals      @exp_delegate_nm             , @act_delegate_nm             , '090 delegate_nm mismatch';
            IF @exp_status                   IS NOT NULL EXEC tSQLt.AssertEquals      @exp_status                  , @act_status                  , '091 status mismatch';
            IF @exp_first_reg                IS NOT NULL EXEC tSQLt.AssertEquals      @exp_first_reg               , @act_first_reg               , '092 first_reg mismatch';
            IF @exp_quality                  IS NOT NULL EXEC tSQLt.AssertEquals      @exp_quality                 , @act_quality                 , '093 quality mismatch';
            IF @exp_notes                    IS NOT NULL EXEC tSQLt.AssertEquals      @exp_notes                   , @act_notes                   , '094 notes mismatch';
            IF @exp_primary_contact_nm       IS NOT NULL EXEC tSQLt.AssertEquals      @exp_primary_contact_nm      , @act_primary_contact_nm      , '095 primary_contact_id mismatch';
            IF @exp_phone                    IS NOT NULL EXEC tSQLt.AssertEquals      @exp_phone                   , @act_phone                   , '096 phone mismatch';
            IF @exp_facebook                 IS NOT NULL EXEC tSQLt.AssertEquals      @exp_facebook                , @act_facebook                , '097 facebook mismatch';
            IF @exp_messenger                IS NOT NULL EXEC tSQLt.AssertEquals      @exp_messenger               , @act_messenger               , '098 messenger mismatch';
            IF @exp_preferred_contact_method IS NOT NULL EXEC tSQLt.AssertEquals      @exp_preferred_contact_method, @act_preferred_contact_method, '099 preferred_contact_method mismatch';
            IF @exp_email                    IS NOT NULL EXEC tSQLt.AssertEquals      @exp_email                   , @act_email                   , '100 email mismatch';
            IF @exp_WhatsApp                 IS NOT NULL EXEC tSQLt.AssertEquals      @exp_WhatsApp                , @act_WhatsApp                , '101 WhatsApp mismatch';
            IF @exp_viber                    IS NOT NULL EXEC tSQLt.AssertEquals      @exp_viber                   , @act_viber                   , '102 viber mismatch';
            IF @exp_website                  IS NOT NULL EXEC tSQLt.AssertEquals      @exp_website                 , @act_website                 , '103 website mismatch';
            IF @exp_Address                  IS NOT NULL EXEC tSQLt.AssertEquals      @exp_Address                 , @act_Address                 , '104 Address mismatch';
         END

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
EXEC tSQLt.Run 'test.test_084_sp_merge_agency_tbl';
*/