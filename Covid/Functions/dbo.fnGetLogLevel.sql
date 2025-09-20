SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==========================================================
-- Author:      Terry
-- Create date: 25-JUL-2024
-- Description: Gets the current logging level from settings
-- ==========================================================
CREATE FUNCTION [dbo].[fnGetLogLevel]()
RETURNS INT
AS
BEGIN
   RETURN CONVERT(INT, SESSION_CONTEXT(dbo.fnGetLogLevelKey()));
END
/*
EXEC sp_set_log_level 1
PRINT dbo.fnGetLogLevel();
EXEC sp_set_log_level 0
PRINT dbo.fnGetLogLevel();
EXEC sp_set_log_level 4
PRINT dbo.fnGetLogLevel();
EXEC tSQLt.RunAll
EXEC sp_set_log_level 1
PRINT dbo.fnGetLogLevel();
*/

GO
