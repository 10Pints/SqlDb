--==========================================================================
-- Author:           Terry Watts
-- Create date:      03-Oct-2025
-- Rtn:              test.test_085_sp_import_AgencyType
-- Description: main test routine for the dbo.sp_import_AgencyType routine 
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
CREATE PROCEDURE test.test_085_sp_import_AgencyType
AS
BEGIN
DECLARE
   @fn VARCHAR(35) = 'test_085_sp_import_AgencyType'

   EXEC test.sp_tst_mn_st @fn;

   -- 1 off setup  ??
   EXEC test.hlpr_085_sp_import_AgencyType
       @tst_num            = '001'
      ,@display_tables     = 1
      ,@inp_file           = 'D:\Dev\CRM\SQL\Tests\085_sp_import_AgencyType\Property Sales 251002-1200.xlsx'
      ,@inp_worksheet      = 'Lists'
      ,@inp_range          = 'F2:G15'
      ,@exp_row_cnt        = 8
      ,@exp_first_id       = 1
      ,@exp_first_nm       = 'Agent'
      ,@exp_last_id        = 8
      ,@exp_last_nm        = 'Other'
      ,@exp_ex_num         = NULL
      ,@exp_ex_msg         = NULL
   ;

   EXEC sp_log 2, @fn, '99: All subtests PASSED'
   EXEC test.sp_tst_mn_cls;
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_085_sp_import_AgencyType';
*/
