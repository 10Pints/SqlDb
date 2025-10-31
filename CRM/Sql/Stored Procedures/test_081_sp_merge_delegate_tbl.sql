--===========================================================================
-- Author:           Terry Watts
-- Create date:      02-Oct-2025
-- Rtn:              test.test_081_sp_merge_delegate_tbl
-- Description: main test routine for the dbo.sp_merge_delegate_tbl routine 
--
-- Tested rtn description:
-- Merges teh Delegate table from PropertySalesStaging
-- EXEC tSQLt.Run 'test.test_<nnn>_<proc_nm>';
-- Design:
-- Tests:
--===========================================================================
CREATE PROCEDURE [test].[test_081_sp_merge_delegate_tbl]
AS
BEGIN
DECLARE
    @fn     VARCHAR(35) = 'test_081_sp_merge_delegate_tbl'
   ,@cnt    INT

   EXEC test.sp_tst_mn_st @fn;

   -- 1 off setup import a known staging table
   EXEC @cnt = sp_import_propertySalesStaging
       @file            = 'D:\Dev\CRM\SQL\Tests\081_sp_merge_delegate_tbl\Property Sales 251002-1200.xlsx'
      ,@worksheet       = 'Resort Sale'
      ,@range           = 'A1:AA1000'
      ,@display_tables  = 1
   ;

   DELETE FROM Delegate;

   EXEC tSQLt.AssertEquals 108, @cnt,  'Setup expected 108 rows, and got ',@cnt;

   EXEC test.hlpr_081_sp_merge_delegate_tbl
       @tst_num            = '001'
      ,@display_tables     = 1
      ,@exp_row_cnt        = 2
      ,@exp_rc             = 2
      ,@exp_ex_num         = NULL
      ,@exp_ex_msg         = NULL
   ;

   EXEC sp_log 2, @fn, '99: All subtests PASSED'
   EXEC test.sp_tst_mn_cls;
END
/*
EXEC test.test_081_sp_merge_delegate_tbl;

EXEC tSQLt.Run 'test.test_081_sp_merge_delegate_tbl';
EXEC tSQLt.RunAll;
*/