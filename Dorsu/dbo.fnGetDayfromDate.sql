SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =======================================================================
-- Author:      Terry Watts
-- Create date: 01-MAY-2025
-- Description: Gets the short dat name like {}MON, TYU, WEd, THU, FRI}
-- Design:      NONE
-- Tests:       test_053_GetDayfromDate
-- =======================================================================
CREATE FUNCTION [dbo].[fnGetDayfromDate](@dt DATE)
RETURNS VARCHAR(3)
AS
BEGIN
   RETURN UPPER(SUBSTRING (DATENAME(dw, @dt), 1, 3));
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_053_fnGetDayfromDate;
*/

GO
