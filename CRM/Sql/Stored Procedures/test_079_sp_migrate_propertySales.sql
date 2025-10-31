--====================================================================================
-- Author:           Terry Watts
-- Create date:      15-Sep-2025
-- Rtn:              test.test_079_sp_migrate_property_sales_data
-- Description: main test routine for the dbo.sp_migrate_property_sales_data routine 
--
-- Tested rtn description:
-- Migrates the Resort Sales staging data to ResortSales
--
-- Preconditions:
-- PRE01: ResortSalesStaging table is populated
-- Postconditions:
-- POST01: ResortSales is populated
-- POST 01
--====================================================================================
CREATE PROCEDURE [test].[test_079_sp_migrate_propertySales]
AS
BEGIN
DECLARE
    @fn VARCHAR(35) = 'test_079_sp_migrate_sp_migrate_propertySales'
   ,@rc INT

   EXEC test.sp_tst_mn_st @fn;

   -- 1 off setup  ??
   EXEC @rc = sp_import_propertySalesStaging 
             'D:\Dev\CRM\SQL\Tests\078_sp_import_property_sales\Property Sales.xlsx'
            ,'Resort Sale'
            ,'A1:AA93'
            ,0
            ;

   EXEC sp_assert_tbl_pop 'PropertySalesStaging', @exp_cnt = 92;

   -- ASSERTION test data loaded

   EXEC test.hlpr_079_sp_migrate_PropertySales
       @tst_num               = '001 1 phone number agnt nmd'
      ,@display_tables        = 1
      ,@inp_file              = 'D:\Dev\CRM\SQL\Tests\078_sp_import_property_sales\Property Sales.xlsx'
      ,@inp_worksheet         = 'Resort Sale'
      ,@inp_range             = 'A1:AA93'
      ,@exp_row_cnt           = 92
      ,@inp_agency_nm         = 'Property Seeker Realty'
      ,@exp_agency_phone      = '0977 850 6749'
      ,@exp_agency_cnt        = 92
      ,@exp_contact_cnt       = 3
      ,@exp_contactAgency_cnt = 1
   ;

   RETURN;

   EXEC test.hlpr_079_sp_migrate_PropertySales
       @tst_num               = '002 M phone numbers no agnt with list'
      ,@display_tables        = 1
      ,@inp_file              = 'D:\Dev\CRM\SQL\Tests\078_sp_import_property_sales\Property Sales.xlsx'
      ,@inp_worksheet         = 'Resort Sale'
      ,@inp_range             = 'A1:AA93'
      ,@exp_row_cnt           = 92
      ,@inp_agency_nm         = 'PropertyBroker.PH Corporation'
      ,@exp_agency_phone      = '09079268813'
      ,@exp_agency_cnt        = 92
      ,@exp_contact_cnt       = 3
      ,@exp_contactAgency_cnt = 1
   ;

   EXEC test.hlpr_079_sp_migrate_PropertySales
       @tst_num               = '003 M phone number no agnt with list'
      ,@display_tables        = 1
      ,@inp_file              = 'D:\Dev\CRM\SQL\Tests\078_sp_import_property_sales\Property Sales.xlsx'
      ,@inp_worksheet         = 'Resort Sale'
      ,@inp_range             = 'A1:AA93'
      ,@exp_row_cnt           = 92
      ,@inp_agency_nm         = 'MDA Dream Realty & Brokerage'
      ,@exp_agency_phone      = '0936 892 2275'
      ,@exp_agency_cnt        = 92
      ,@exp_contact_cnt       = 3
      ,@exp_contactAgency_cnt = 1
   ;

   EXEC sp_log 2, @fn, '99: All subtests PASSED'
   EXEC test.sp_tst_mn_cls;
END
/*
EXEC test.test_079_sp_migrate_propertySales;

EXEC tSQLt.Run 'test.test_079_sp_migrate_propertySales';
*/