--=====================================================================
-- Author:           Terry Watts
-- Create date:      05-Sep-2025
-- Rtn:              test.test_072_fnWrapFieldName
-- Description: main test routine for the dbo.fnWrapFieldName routine 
--
-- Tested rtn description:
--
-- Design:
-- Tests:
--=====================================================================
CREATE PROCEDURE test.test_072_fnWrapFieldName
AS
BEGIN
DECLARE
   @fn VARCHAR(35) = 'test_072_fnWrapFieldName'

   EXEC test.sp_tst_mn_st @fn;

   EXEC test.hlpr_072_fnWrapFieldName '001', NULL, NULL, NULL, NULL;
   EXEC test.hlpr_072_fnWrapFieldName '002', '', '', NULL, NULL;
   EXEC test.hlpr_072_fnWrapFieldName '003', 'info', 'info', NULL, NULL;
   EXEC test.hlpr_072_fnWrapFieldName '004', 'name', '[name]', NULL, NULL;
   EXEC test.hlpr_072_fnWrapFieldName '005', 'description', '[description]', NULL, NULL;
   EXEC test.hlpr_072_fnWrapFieldName '006', 'abs', '[abs]', NULL, NULL;
   EXEC test.hlpr_072_fnWrapFieldName '007', 'ABS', '[ABS]', NULL, NULL;
   EXEC test.hlpr_072_fnWrapFieldName '008', 'WRITETEXT', '[WRITETEXT]', NULL, NULL;
   EXEC test.hlpr_072_fnWrapFieldName '009', 'writetext', '[writetext]', NULL, NULL;
   EXEC test.hlpr_072_fnWrapFieldName '010', 'date', '[date]', NULL, NULL;
   EXEC test.hlpr_072_fnWrapFieldName '011', 'current_date', '[current_date]', NULL, NULL;
   EXEC test.hlpr_072_fnWrapFieldName '012', 'status', '[status]', NULL, NULL;
   EXEC test.hlpr_072_fnWrapFieldName '012', 'STATUS', '[STATUS]', NULL, NULL;

   EXEC sp_log 2, @fn, '99: All subtests PASSED'
   EXEC test.sp_tst_mn_cls;
END
/*
EXEC tSQLt.Run 'test.test_072_fnWrapFieldName';

EXEC tSQLt.RunAll;
*/