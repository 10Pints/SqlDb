﻿

-- ===============================================================
-- Author:      Terry
-- Create date: 05-FEB-2021
-- Description: accessor: error_state
-- Tests: test_049_SetGetCrntTstValue
-- ===============================================================
CREATE FUNCTION [test].[fnGetCrntTstErrSt]()
RETURNS INT
AS
BEGIN
   RETURN CONVERT( INT, SESSION_CONTEXT(test.fnGetCrntTstErrStKey()));
END
/*
PRINT [test].[fnGetCrntTstErrSt]()
*/



