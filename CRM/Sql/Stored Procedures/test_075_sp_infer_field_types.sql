--==========================================================================
-- Author:           Terry Watts
-- Create date:      17-Jun-2025
-- Rtn:              test.test_074_sp_infer_field_types
-- Description: main test routine for the dbo.sp_infer_field_types routine 
--
-- Tested rtn description:
-- infers the field types froma staging table
--    based on its data
--
-- EXEC tSQLt.Run 'test.test_<nnn>_<proc_nm>';
-- Design:
-- Tests:
--==========================================================================
CREATE PROCEDURE [test].[test_075_sp_infer_field_types]
AS
BEGIN
DECLARE
   @fn VARCHAR(35) = 'test_075_sp_infer_field_types'

   EXEC test.sp_tst_mn_st @fn;

   -- Property Sales - Resort SaleStaging
   EXEC test.hlpr_075_sp_infer_field_types
       @tst_num            = '001'
      ,@display_tables     = 1
      ,@inp_q_table_nm     = 'dbo.PropertySales Staging'
      ,@exp_row_cnt        = NULL
      ,@exp_rc             = NULL
      ,@exp_ex_num         = 50001
      ,@exp_ex_msg         = 'Table dbo.PropertySales Staging does not exist but should'
   ;

   -- Preconditions: PRE01: table must exist or exception 50001 'Table '<@q_table_nm> does not exist
   EXEC test.hlpr_075_sp_infer_field_types
       @tst_num            = '002'
      ,@display_tables     = 1
      ,@inp_q_table_nm     = '[test].[TstDef]'
      ,@exp_row_cnt        = 2
      ,@exp_rc             = 0
      ,@exp_ex_num         = NULL
      ,@exp_ex_msg         = NULL
   ;

   EXEC test.hlpr_075_sp_infer_field_types
       @tst_num            = '003'
      ,@display_tables     = 1
      ,@inp_q_table_nm     = '[test].[TstDef]'
      ,@exp_row_cnt        = 2
      ,@exp_rc             = 0
      ,@exp_ex_num         = NULL
      ,@exp_ex_msg         = NULL
   ;
   EXEC sp_log 2, @fn, '99: All subtests PASSED'
   EXEC test.sp_tst_mn_cls;
END
/*
EXEC test.test_075_sp_infer_field_types;
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_075_sp_infer_field_types';
SELECT * FROM FieldInfo;
*/
