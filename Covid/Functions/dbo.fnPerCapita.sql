SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry watta
-- Create date: 27-APR-2020
-- Description: returns the value of @total per million pop value
--              rounded to 2 dp
-- =============================================
CREATE FUNCTION [dbo].[fnPerCapita] 
(
     @total     FLOAT
    ,@pop       FLOAT
    ,@dp        INT   = NULL
)
RETURNS FLOAT
AS
BEGIN
   IF @dp IS NULL SET @dp = 2;

   RETURN ROUND(@total/(@pop/1000000.0), @dp);
END

/*
test  print [dbo].[fnPerCapita](6000, 6000000)
*/




GO
