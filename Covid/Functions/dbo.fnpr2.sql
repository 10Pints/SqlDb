SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =================================================
-- Author:      Terry Watts
-- Create date: 20-MAY-2020
-- Description: Pads right with specified character
--              shorthand version
-- =================================================
CREATE FUNCTION [dbo].[fnpr2]( @s NVARCHAR(500), @width INT, @pad  NVARCHAR(1))
RETURNS NVARCHAR (4000)
AS
BEGIN
    RETURN UT.dbo.fnPadRight2( @s, @width, @pad);
END





GO
