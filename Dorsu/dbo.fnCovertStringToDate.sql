SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==================================================
-- Description: Convers a date like 23-Feb to a DATE
-- Design:      
-- Tests:       
-- Author:      
-- Create date: 
-- ==================================================
CREATE FUNCTION [dbo].[fnCovertStringToDate]( @StringDate VARCHAR(20))
RETURNS DATE
AS
BEGIN

-- Extract components (assuming consistent format)
DECLARE 
    @Day           VARCHAR(2) = PARSENAME(REPLACE(@StringDate, '-', '.'), 2) -- '21'
   ,@Month         VARCHAR(3) = PARSENAME(REPLACE(@StringDate, '-', '.'), 1) -- 'Feb'
   ,@Year          VARCHAR(4) = Year(GetDate())
   ,@FormattedDate VARCHAR(20);

   -- Combine into a standard format and convert to date
   SET @FormattedDate = CONCAT(@Day, '-', @Month, '-', @Year);

   RETURN CONVERT(DATE, @FormattedDate, 106);
END
/*
EXEC tSQLt.Run 'test.test_015_fnCovertStringToDate';

EXEC tSQLt.RunAll;
*/

GO
