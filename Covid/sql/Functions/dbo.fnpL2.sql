SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =================================================
-- Author:      Terry Watts
-- Create date: 01-JUN-2020
-- Description: Pads right with specified character
--              shorthand version
-- =================================================
CREATE FUNCTION [dbo].[fnpL2]( @s NVARCHAR(500), @width INT, @pad  NVARCHAR(1))
RETURNS NVARCHAR (4000)
AS
BEGIN
    RETURN UT.dbo.fnPadLeft2( @s, @width, @pad);
END


/*
GO
PRINT FORMAT(1, 'N2')
PRINT FORMAT(1, '00.00')

PRINT CONCAT('[', [dbo].[fnpL2]('asdf', 0, ' '), ']');
--PRINT CONCAT('[', [dbo].[fnpL2]('asdf', -1, ' '), ']');
PRINT CONCAT('[', [dbo].[fnpL2]('', 0, ' '), ']');
PRINT CONCAT('[', [dbo].[fnpL2]('', 1, ' '), ']');
PRINT CONCAT('[', [dbo].[fnpL2]('asdf', 3, ' '), ']');
PRINT CONCAT('[', [dbo].[fnpL2]('asdf', 4, ' '), ']');
PRINT CONCAT('[', [dbo].[fnpL2]('asdf', 5, ' '), ']');
*/





GO
