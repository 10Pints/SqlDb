SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry watta
-- Create date: 11-JAN-2021
-- Description: returns the value of @total as a percentager of pop value
-- =============================================
CREATE FUNCTION [dbo].[fnPerCentOfPop2] 
(
    @total  FLOAT
   ,@pop    FLOAT
   ,@dp     INT
)
RETURNS FLOAT
AS
BEGIN
   RETURN ROUND(@total*100.0/@pop, @dp)
END

/*
--test  
print [dbo].[fnPerCentOfPop2](6000, 6000000, default)
print [dbo].[fnPerCentOfPop2](6000, 6000000, 5)
SELECT * FROM country WHERE name = 'United Kingdom'
*/





GO
