--==============================================================================
-- Author:           Terry Watts
-- Create date:      12-Sep-2025
-- Rtn:              test.test_078_sp_import_property_sales
-- Description: main test routine for the dbo.sp_import_property_sales routine 
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
CREATE PROCEDURE [test].[test_078_sp_import_PropertySales]
AS
BEGIN
DECLARE
   @fn VARCHAR(35) = 'test_078_sp_import_PropertySales'

   EXEC test.sp_tst_mn_st @fn;

   -- 1 off setup  ??
   EXEC test.hlpr_078_sp_import_PropertySales
       @tst_num               = '001'
      ,@display_tables        = 1
      ,@inp_file              = 'D:\Dev\CRM\SQL\Tests\078_sp_import_property_sales\Property Sales 251002-1200.xlsx'
      ,@inp_worksheet         = 'Resort Sale'
      ,@inp_range             = 'A1:AC1000'
      ,@exp_row_cnt           = 108
      ,@exp_rc                = 0
      ,@exp_agency_cnt        = 108
      ,@exp_contact_cnt       = 63
      ,@exp_contactAgency_cnt = 2
      ,@exp_ex_num            = NULL
      ,@exp_ex_msg            = NULL
   ;

   EXEC sp_log 2, @fn, '99: All subtests PASSED'
   EXEC test.sp_tst_mn_cls;
END
/*
EXEC test.test_078_sp_import_PropertySales;
EXEC tSQLt.Run 'test.test_078_sp_import_PropertySales';
EXEC tSQLt.RunAll;
*/