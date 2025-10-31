

-- =============================================
-- Author:      Terry Watts
-- Create date: 25-NOV-2023
-- Description: returns the log level
-- =============================================
CREATE FUNCTION [dbo].[fnGetLogLevel]()
RETURNS INT
AS
BEGIN
   RETURN dbo.fnGetSessionContextAsInt(dbo.fnGetLogLevelKey());
END
/*
EXEC test.sp_crt_tst_rtns 'dbo.fnGetLogLevel', 80;
*/



