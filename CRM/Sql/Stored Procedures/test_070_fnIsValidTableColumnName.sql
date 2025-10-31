--==============================================================================
-- Author:           Terry Watts
-- Create date:      05-Sep-2025
-- Rtn:              test.test_070_fnIsValidTableColumnName
-- Description: main test routine for the dbo.fnIsValidTableColumnName routine 
--
-- Tested rtn description:
--
-- Design:
-- Tests:
-- Author:
-- Create date:
--==============================================================================
CREATE PROCEDURE test.test_070_fnIsValidTableColumnName
AS
BEGIN
DECLARE
   @fn VARCHAR(35) = 'test_070_fnIsValidTableColumnName'

   EXEC test.sp_tst_mn_st @fn;

   -- 1 off setup  ??
   EXEC test.hlpr_070_fnIsValidTableColumnName  '001','', 0;
   EXEC test.hlpr_070_fnIsValidTableColumnName  '001',' ', 0;
   EXEC test.hlpr_070_fnIsValidTableColumnName  '002','a', 1;
   EXEC test.hlpr_070_fnIsValidTableColumnName  '003','a b', 0;
   EXEC test.hlpr_070_fnIsValidTableColumnName  '004','SET', 0;
   EXEC test.hlpr_070_fnIsValidTableColumnName  '005','DATE', 0;
   EXEC test.hlpr_070_fnIsValidTableColumnName  '006','date', 0;

   EXEC sp_log 2, @fn, '99: All subtests PASSED'
   EXEC test.sp_tst_mn_cls;
END
/*
EXEC tSQLt.Run 'test.test_070_fnIsValidTableColumnName';
*/