--=========================================================================
-- Author:           Terry Watts
-- Create date:      02-Oct-2025
-- Rtn:              test.test_084_sp_merge_agency_tbl
-- Description: main test routine for the dbo.sp_merge_agency_tbl routine 
--
-- Tested rtn description:
-- Merges the Agency table from PropertySalesStaging
-- Returns      the merge count
-- Design:
-- Tests:
--=========================================================================
CREATE PROCEDURE [test].[test_084_sp_merge_agency_tbl]
AS
BEGIN
DECLARE
   @fn   VARCHAR(35) = 'test_084_sp_merge_agency_tbl'
  ,@cnt  INT;

   EXEC test.sp_tst_mn_st @fn;

   -- 1 off setup
   EXEC @cnt = sp_import_propertySalesStaging
       @file            = 'D:\Dev\CRM\SQL\Tests\084_sp_merge_agency_tbl\Property Sales 251002-1200.xlsx'
      ,@worksheet       = 'Resort Sale'
      ,@range           = 'A1:AA1000'
      ,@display_tables  = 1
   ;
   -- assert data setup loaded ok
   EXEC tSQLt.AssertEquals 108, @cnt,  'Setup expected 108 rows, and got ',@cnt;

   EXEC test.hlpr_084_sp_merge_agency_tbl
       @tst_num                     = '001'
      ,@display_tables              = 1
      ,@exp_row_cnt                 = 108
      ,@exp_ex_num                  = NULL
      ,@exp_ex_msg                  = NULL
      ,@tst_agency_nm               = '0961 168 9267'
      ,@exp_agency_type_nm          = 'Direct LAM'
      ,@exp_area                    = 'Unknown Area'
      ,@exp_delegate_nm             = 'T'
      ,@exp_status                  = 'Cannot be reached'
      ,@exp_first_reg               = '20-AUG-2025'
      ,@exp_notes                   = 'unknown notes'
      ,@exp_quality                 = 2
      ,@exp_primary_contact_nm      = 'unknown contact name'
      ,@exp_role                    = 'unknown role'
      ,@exp_phone                   = '0961 168 9267'
      ,@exp_facebook                = 'unknown facebook'
      ,@exp_messenger               = 'unknown  messenger'
      ,@exp_preferred_contact_method= 'unknown  preferred contact method'
      ,@exp_email                   = 'unknown  email'
      ,@exp_WhatsApp                = 'unknown WhatsApp'
      ,@exp_viber                   = 'unknown viber'
      ,@exp_website                 = 'unknown  website'
      ,@exp_Address                 = 'unknown  address'
      ,@exp_Notes_2                 = 'unknown  notes 2'
      ,@exp_Old_Notes               = 'unknown  old_notes'
      ,@exp_age                     = '30'
      ,@exp_Actions_08_OCT          = 'unknown  actions'
      ,@exp_Jan_16_2025             = 'unknown Jan 16 2025'
      ,@exp_Action_By_dt            = 'unknown action by dt'
      ,@exp_Replied                 = 'unknown replied'
      ,@exp_History                 = 'unknown  history'
   ;

   EXEC sp_log 2, @fn, '99: All subtests PASSED'
   EXEC test.sp_tst_mn_cls;
END
/*
EXEC test.test_084_sp_merge_agency_tbl;
EXEC tSQLt.Run 'test.test_084_sp_merge_agency_tbl';
EXEC tSQLt.RunAll;
*/