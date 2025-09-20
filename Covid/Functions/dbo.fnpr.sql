SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 22-MAR-2020
-- Description: Pads right - shorthand version
-- =============================================    
CREATE FUNCTION [dbo].[fnpr]( @s NVARCHAR(500), @width INT)
RETURNS NVARCHAR (4000)
AS
BEGIN
    RETURN UT.dbo.fnPadRight( @s, @width)
END





GO
