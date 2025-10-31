--==========================================================================
-- Author:           Terry Watts
-- Create date:      02-Oct-2025
-- Rtn:              test.test_083_sp_merge_contact_tbl
-- Description: main test routine for the dbo.sp_merge_contact_tbl routine 
--
-- Tested rtn description:
-- Merges the Delegate table from PropertySalesStaging
-- Returns      the merge count
-- Design:
-- Tests:
--==========================================================================
CREATE PROCEDURE [test].[test_083_sp_merge_contact_tbl]
AS
BEGIN
DECLARE
    @fn  VARCHAR(35) = 'test_083_sp_merge_contact_tbl'

   EXEC test.sp_tst_mn_st @fn;

   -- 1 off setup import a known staging table
   DECLARE @cnt INT;
   EXEC @cnt = sp_import_propertySalesStaging
       @file            = 'D:\Dev\CRM\SQL\Tests\083_sp_merge_contact_tbl\Property Sales 251002-1200.xlsx'
      ,@worksheet       = 'Resort Sale'
      ,@range           = 'A1:AA1000'
      ,@display_tables  = 1
   ;
   EXEC tSQLt.AssertEquals 108, @cnt,  'Setup expected 108 rows, and got ',@cnt;

   -- 1 off setup  ??
   EXEC test.hlpr_083_sp_merge_contact_tbl
       @tst_num                    = '001'
      ,@display_tables             = 1
      ,@exp_row_cnt                = 63
      ,@exp_contact_id             = NULL
      ,@exp_contact_nm             = NULL
      ,@exp_role                   = NULL
      ,@exp_phone                  = NULL
      ,@exp_viber                  = NULL
      ,@exp_whatsapp               = NULL
      ,@exp_facebook               = NULL
      ,@exp_messenger              = NULL
      ,@exp_primary_contact_type   = NULL
      ,@exp_primary_contact_detail = NULL
      ,@exp_last_contacted         = NULL
      ,@exp_is_active              = NULL
      ,@exp_sex                    = NULL
      ,@exp_age                    = NULL
      ,@exp_ex_num                 = NULL
      ,@exp_ex_msg                 = NULL
   ;

   EXEC sp_log 2, @fn, '99: All subtests PASSED'
   EXEC test.sp_tst_mn_cls;
END
/*
EXEC test.test_083_sp_merge_contact_tbl;
EXEC tSQLt.Run 'test.test_083_sp_merge_contact_tbl';

EXEC tSQLt.RunAll;
*/