﻿

-- =============================================
-- Author:      Terry watts
-- Create date: 05-FEB-2021
-- Description: Setter: for the test helper fn
-- Tests: [test].[test 030 chkTestConfig]
-- =============================================
CREATE PROCEDURE [test].[sp_tst_set_crnt_tst_hlpr_fn] @val VARCHAR(100)
AS
BEGIN
   DECLARE @key NVARCHAR(60) = test.fnGetCrntTstHlprFnKey()
   EXEC sp_set_session_context @key, @val;
END
/*
EXEC test.[test 030 chkTestConfig]
EXEC tSQLt.Run 'test.test 030 chkTestConfig'
EXEC tSQLt.RunAll
PRINT test.fnGetCrntTstHlprFnNmKey()
*/


