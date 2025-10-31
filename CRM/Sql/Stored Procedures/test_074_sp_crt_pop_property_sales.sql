--===============================================================================
-- Author:           Terry Watts
-- Create date:      09-Sep-2025
-- Rtn:              test.test_074_sp_crt_pop_property_sales
-- Description: main test routine for the dbo.sp_crt_pop_property_sales routine 
--
-- Tested rtn description:
-- Clean populates the Property sales tables
-- EXEC tSQLt.Run 'test.test_<nnn>_<proc_nm>';
-- Design:
-- Tests:
--===============================================================================
CREATE PROCEDURE [test].[test_074_sp_crt_pop_property_sales]
AS
BEGIN
DECLARE
   @fn VARCHAR(35) = 'test_075_sp_crt_pop_property_sales'

   EXEC test.sp_tst_mn_st @fn;

   -- 1 off setup  ??
   EXEC test.hlpr_074_sp_crt_pop_property_sales
       @tst_num            = '001'
      ,@inp_file_path      = 'D:\Dev\CRM\SQL\Tests\074_sp_crt_pop_property_sales\PropertySales.tsv'
      ,@inp_table_nm       = 'Test.PropertySalesStaging'
      ,@display_tables     = 1
      ,@exp_row_cnt        = NULL
      ,@exp_rc             = NULL
      ,@exp_ex_num         = NULL
      ,@exp_ex_msg         = NULL
   ;

   EXEC sp_log 2, @fn, '99: All subtests PASSED'
   EXEC test.sp_tst_mn_cls;
END
/*
EXEC test.test_074_sp_crt_pop_property_sales;
EXEC tSQLt.Run 'test.test_074_sp_crt_pop_property_sales';
EXEC tSQLt.RunAll;
*/