--====================================================================================
-- Author:           Terry Watts
-- Create date:      02-Oct-2025
-- Rtn:              test.test_082_sp_import_propertySalesStaging
-- Description: main test routine for the dbo.sp_import_propertySalesStaging routine 
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
CREATE PROCEDURE [test].[test_082_sp_import_propertySalesStaging]
AS
BEGIN
DECLARE
   @fn VARCHAR(35) = 'test_082_sp_import_propertySalesStaging'

   EXEC test.sp_tst_mn_st @fn;

   -- 1 off setup  ??
   EXEC test.hlpr_082_sp_import_propertySalesStaging
       @tst_num            = '001'
      ,@display_tables     = 1
      ,@inp_file           = 'D:\Dev\CRM\SQL\Tests\082_sp_import_propertySalesStaging\Property Sales 251002-1200.xlsx'
      ,@inp_worksheet      = 'Resort Sale'
      ,@inp_range          = 'A1:AA1000'
      ,@exp_row_cnt        = 108
      ,@exp_rc             = 108
      ,@exp_ex_num         = NULL
      ,@exp_ex_msg         = NULL
   ;

   EXEC sp_log 2, @fn, '99: All subtests PASSED'
   EXEC test.sp_tst_mn_cls;
END
/*
EXEC test.test_082_sp_import_propertySalesStaging;

EXEC tSQLt.Run 'test.test_082_sp_import_propertySalesStaging';
EXEC tSQLt.RunAll;
*/