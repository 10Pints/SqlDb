﻿

-- ===============================================================
-- Author:      Terry Watts
-- Create date: 03-DEC-2024
-- Description: gets the current sub test identifier
-- ===============================================================
CREATE FUNCTION [test].[fnGetCrntSubTst]()
RETURNS VARCHAR(100)
AS
BEGIN
   RETURN CONVERT(VARCHAR(100), SESSION_CONTEXT(test.fnGetCrntSubTstKey()));
END
/*
PRINT test.fnGetCrntSubTst();
EXEC tSQLt.RunAll;
*/


