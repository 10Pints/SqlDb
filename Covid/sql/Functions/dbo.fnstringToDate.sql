SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 11-MAY-2020
-- Description: Converts a string MM-DD-YYYY to a date
--              Date like: 05-20-2020
-- =============================================
CREATE FUNCTION [dbo].[fnstringToDate](@str NVARCHAR(20))
RETURNS DATE
AS
BEGIN
   RETURN Cast(@str AS DATE)
END




GO
