SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===============================================================
-- Author:      Terry
-- Create date: 04-AUG-2024
-- Description: Returns the log cache
-- ===============================================================
CREATE FUNCTION [dbo].[fnGetLogCache]()
RETURNS BIT
AS
BEGIN
   RETURN CONVERT(NVARCHAR(4000), SESSION_CONTEXT(dbo.fnGetLogCacheKey()));
END

GO
