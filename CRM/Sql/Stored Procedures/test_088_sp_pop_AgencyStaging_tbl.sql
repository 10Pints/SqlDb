--==============================================================================
-- Author:           Terry Watts
-- Create date:      22-Oct-2025
-- Rtn:              test.test_088_sp_pop_AgencyStaging_tbl
-- Description: main test routine for the dbo.sp_pop_AgencyStaging_tbl routine 
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
CREATE PROCEDURE [test].[test_088_sp_pop_AgencyStaging_tbl]
AS
BEGIN
DECLARE
   @fn VARCHAR(35) = 'test_088_sp_pop_AgencyStaging_tbl'

   EXEC test.sp_tst_mn_st @fn;

   ------------------------------------------------------------------------
   -- 1 off setup
   ------------------------------------------------------------------------

   -- Preconditions:
   -- PRE01: PropertySalesStaging popd
   EXEC sp_import_propertySalesStaging
       @file            = 'D:\Dev\CRM\SQL\Tests\088_sp_pop_AgencyStaging_tbl\test_088_sp_pop_AgencyStaging_tbl.xlsx'
      ,@worksheet       = 'PropertySalesStaging'
      ,@range           = 'A1:AA300'
      ,@display_tables  = 1
   ;

   EXEC sp_assert_tbl_pop 'PropertySalesStaging', @exp_cnt = 108;

   ------------------------------------------------------------------------
   -- ASSERTION: All preconditions met
   ------------------------------------------------------------------------

   ------------------------------------------------------------------------
   -- Runb Tests:
   ------------------------------------------------------------------------
   EXEC test.hlpr_088_sp_pop_AgencyStaging_tbl
       @tst_num               = '001'
      ,@display_tables        = 1
      ,@exp_row_cnt           = 108
      ,@tst_agency_nm         = 'unknown agency'
      ,@exp_delegate_nm       = 'T'
      ,@exp_phone             = '0961 168 9267'
      ,@exp_viber             = 'unknown viber'
      ,@exp_whatsApp          = 'unknown WhatsApp'
      ,@exp_facebook          = 'unknown facebook'
      ,@exp_messenger         = 'unknown messenger'
      ,@exp_website           = 'unknown website'
      ,@exp_email             = 'unknown email'
      ,@exp_primary_contact_nm= 'unknown contact name'
      ,@exp_address           = 'unknown address'
      ,@exp_notes_2           = 'unknown notes 2'
      ,@exp_age               = 30
      ,@exp_Actions_08_OCT    = 'unknown actions 08-OCT'
      ,@exp_jan_16_2025       = 'unknown Jan 16 2025'
      ,@exp_Action_by_dt      = 'unknown action by dt'
      ,@exp_replied           = 'unknown replied'
      ,@exp_history           = 'unknown history'
   ;

   EXEC sp_log 2, @fn, '99: All subtests PASSED'
   EXEC test.sp_tst_mn_cls;
END
/*
EXEC test.test_088_sp_pop_AgencyStaging_tbl;
EXEC tSQLt.Run 'test.test_088_sp_pop_AgencyStaging_tbl';
SELECT max(dbo.fnLen(notes)) FROM PropertySalesStaging;

EXEC tSQLt.RunAll;
SELECT * FROM PropertySalesStaging;
*/