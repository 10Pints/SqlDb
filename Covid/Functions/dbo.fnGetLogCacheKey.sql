SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===============================================================
-- Author:      Terry
-- Create date: 04-AUG-2024
-- Description: Gets the was caching log context key
-- Key:         N'Tested fn'
-- Tests:       test.test 030 chkTestConfig
-- ===============================================================
CREATE FUNCTION [dbo].[fnGetLogCacheKey]()
RETURNS NVARCHAR(60)
AS
BEGIN
   RETURN N'log cache';
END


GO
