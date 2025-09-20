SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry watta
-- Create date: 11-JAN-2021
-- Description: returns the value of @total as a percentager of pop value
-- =============================================
CREATE FUNCTION [dbo].[fnPerCentOfPop] 
(
     @total    FLOAT
    ,@pop      FLOAT
)
RETURNS FLOAT
AS
BEGIN
    RETURN [dbo].[fnPerCentOfPop2](@total, @pop, 2)
END


/*
--test  
print [dbo].[fnPerCentOfPop](6000, 6000000)
print [dbo].[fnPerCentOfPop](6000, 6000000, 5)
*/





GO
