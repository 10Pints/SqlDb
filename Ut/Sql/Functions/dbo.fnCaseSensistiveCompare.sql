SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 18-DEC-2019
-- Description: case sensitive compare helper function
-- Returns:     1 if match false 0
-- =============================================
CREATE FUNCTION [dbo].[fnCaseSensistiveCompare]
(
    @exp        VARCHAR(MAX)
   ,@act        VARCHAR(MAX)
)
RETURNS BIT
AS
BEGIN
   IF @exp IS NULL AND @act IS NULL
      RETURN 1;
   IF (@exp IS NULL     AND @act IS NOT NULL) OR
      (@exp IS NOT NULL AND @act IS NULL)
      RETURN 0;
   RETURN IIF( @exp COLLATE Latin1_General_CS_AS  = @act COLLATE Latin1_General_CS_AS
   , 1, 0);
END

GO

