SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===============================================================
-- Author:      Terry
-- Create date: 04-AUG-2024
-- Description: Returns true if was caching log msg before
-- Key:         N'Tested fn'
-- Tests:       test.test 030 chkTestConfig
-- ===============================================================
CREATE FUNCTION [dbo].[fnWasCachingLog]()
RETURNS BIT
AS
BEGIN
   RETURN CONVERT(BIT, SESSION_CONTEXT(dbo.fnGetWasCachingLogKey()));
END

GO
