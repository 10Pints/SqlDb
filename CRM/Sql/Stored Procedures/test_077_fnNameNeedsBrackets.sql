--=========================================================================
-- Author:           Terry Watts
-- Create date:      09-Sep-2025
-- Rtn:              test.test_077_fnNameNeedsBrackets
-- Description: main test routine for the dbo.fnNameNeedsBrackets routine 
--
-- Tested rtn description:
-- returns 1 if name needs brackets.
--    i.e. is a reserver word or has some wierd characters
-- Design:
-- Tests:
--=========================================================================
CREATE PROCEDURE test.test_077_fnNameNeedsBrackets
AS
BEGIN
DECLARE
   @fn VARCHAR(35) = 'test_077_fnNameNeedsBrackets'

   EXEC test.sp_tst_mn_st @fn;

   EXEC test.hlpr_077_fnNameNeedsBrackets '000', NULL,      1;
   EXEC test.hlpr_077_fnNameNeedsBrackets '001', '',        1;
   EXEC test.hlpr_077_fnNameNeedsBrackets '002', a,         0;
   EXEC test.hlpr_077_fnNameNeedsBrackets '003', '1asd',    1;
   EXEC test.hlpr_077_fnNameNeedsBrackets '004', '!',       1;
   EXEC test.hlpr_077_fnNameNeedsBrackets '005', '@',       1;
   EXEC test.hlpr_077_fnNameNeedsBrackets '006', '#',       1;
   EXEC test.hlpr_077_fnNameNeedsBrackets '007', '$',       1;
   EXEC test.hlpr_077_fnNameNeedsBrackets '008', '*',       1;
   EXEC test.hlpr_077_fnNameNeedsBrackets '009', '%',       1;
   EXEC test.hlpr_077_fnNameNeedsBrackets '010', '^',       1;
   EXEC test.hlpr_077_fnNameNeedsBrackets '011', '&',       1;
   EXEC test.hlpr_077_fnNameNeedsBrackets '012', '*',       1;
   EXEC test.hlpr_077_fnNameNeedsBrackets '013', 'abs(de',  1;
   EXEC test.hlpr_077_fnNameNeedsBrackets '014', 'asd)f',   1;
   EXEC test.hlpr_077_fnNameNeedsBrackets '015', '-',       1;
   EXEC test.hlpr_077_fnNameNeedsBrackets '016', '+',       1;
   EXEC test.hlpr_077_fnNameNeedsBrackets '017', '=',       1;
   EXEC test.hlpr_077_fnNameNeedsBrackets '018', '~',       1;
   EXEC test.hlpr_077_fnNameNeedsBrackets '019', '`',       1;
   EXEC test.hlpr_077_fnNameNeedsBrackets '020', '|',       1;
   EXEC test.hlpr_077_fnNameNeedsBrackets '021', '\\',      1;
   EXEC test.hlpr_077_fnNameNeedsBrackets '022', '/',       1;
   EXEC test.hlpr_077_fnNameNeedsBrackets '023', '?',       1;
   EXEC test.hlpr_077_fnNameNeedsBrackets '024', 'for',     1;
   EXEC test.hlpr_077_fnNameNeedsBrackets '025', 'while',   1;
   EXEC test.hlpr_077_fnNameNeedsBrackets '026', 'for',     1;
   EXEC test.hlpr_077_fnNameNeedsBrackets '027', 'varchar', 1;
   EXEC test.hlpr_077_fnNameNeedsBrackets '027', 'REAL',    1;
   EXEC test.hlpr_077_fnNameNeedsBrackets '027', 'nVarchar',1;
   EXEC test.hlpr_077_fnNameNeedsBrackets '027', 'INT',     1;
   EXEC test.hlpr_077_fnNameNeedsBrackets '027', 'DATE',    1;
   EXEC test.hlpr_077_fnNameNeedsBrackets '027', 'varchar', 1;
   EXEC test.hlpr_077_fnNameNeedsBrackets '028', 'out',     1;

   EXEC sp_log 2, @fn, '99: All subtests PASSED'
   EXEC test.sp_tst_mn_cls;
END
/*
EXEC tSQLt.Run 'test.test_077_fnNameNeedsBrackets';

EXEC tSQLt.RunAll;
*/