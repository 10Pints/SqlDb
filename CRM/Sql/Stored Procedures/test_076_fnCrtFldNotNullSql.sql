-- =======================================================================
-- Author:           Terry Watts
-- Create date:      17-Jun-2025
-- Description: main test routine for the dbo.fnCrtFldNotNullSql routine 
--
-- Tested rtn description:
--
-- =======================================================================
CREATE PROCEDURE [test].[test_076_fnCrtFldNotNullSql]
AS
BEGIN
DECLARE
   @fn VARCHAR(35) = 'test_076_fnCrtFldNotNullSql'

   EXEC test.sp_tst_mn_st @fn;

   EXEC test.hlpr_076_fnCrtFldNotNullSql
       @tst_num         = '001'
      ,@inp_q_table_nm  =  'dbo.Property Sales - Resort SaleStaging'
      ,@inp_fld_nm      = 'FilePath'
      ,@inp_ty          = 'BIT'
      ,@exp_sql         = 'IF NOT EXISTS
(
   SELECT 1 FROM [dbo].[Property Sales - Resort SaleStaging]
   WHERE TRY_CAST([FilePath] AS BIT) IS NULL
)
   SET @fld_ty = ''BIT''
ELSE
   SET @fld_ty = NULL
;'
      ;

   EXEC test.hlpr_076_fnCrtFldNotNullSql
       @tst_num         = '002'
      ,@inp_q_table_nm  = 'dbo.FileActivityLogStaging'
      ,@inp_fld_nm      = 'FilePath'
      ,@inp_ty          = 'BIT'
      ,@exp_sql         = 'IF NOT EXISTS
(
   SELECT 1 FROM [dbo].[FileActivityLogStaging]
   WHERE TRY_CAST([FilePath] AS BIT) IS NULL
)
   SET @fld_ty = ''BIT''
ELSE
   SET @fld_ty = NULL
;'
      ;

   -- 'dbo.Property Sales - Resort SaleStaging'
   EXEC sp_log 2, @fn, '99: All subtests PASSED'
   EXEC test.sp_tst_mn_cls;
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_076_fnCrtFldNotNullSql';

      ,@exp_ex_num         = NULL
      ,@exp_ex_msg         = NULL
   ;
*/
