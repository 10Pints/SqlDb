SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 24-APR-2020
-- Description: Calculates the SR ratio
-- =============================================
CREATE FUNCTION [dbo].[fnCalcSRatio]
(
     @confirmed   INT
    ,@deaths      INT
)
RETURNS FLOAT
AS
BEGIN
    DECLARE 
            @fconf          FLOAT =  CAST(@confirmed AS FLOAT)
           ,@fdead          FLOAT =  CAST(@deaths    AS FLOAT)

    RETURN iif ((@fconf) > 0, ROUND(((@fconf-@fdead) * 100)/@fconf,2), NULL)
END


GO
