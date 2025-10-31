﻿

-- ===============================================================
-- Author:      Terry
-- Create date: 20-NOV-2024
-- Description: Gets the current test hlpr fn name from settings
-- Tests: [test].[test 030 chkTestConfig]
-- ===============================================================
CREATE FUNCTION [test].[fnGetCrntTstHlprFn]()
RETURNS VARCHAR(60)
AS
BEGIN
   RETURN CONVERT(VARCHAR(60), SESSION_CONTEXT(test.fnGetCrntTstHlprFnKey()));
END
/*
PRINT [test].[fnGetCrntTstHlprFn]()
EXEC tSQLt.RunAll
*/


