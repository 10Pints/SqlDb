SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 18-MAY-2025
-- Description: 
-- Tests:       
-- =============================================
CREATE FUNCTION [dbo].[fnHasDuplicateCharacters] (@input NVARCHAR(MAX))
RETURNS BIT
AS
BEGIN
    DECLARE @result BIT = 0;

    IF @input IS NULL OR @input = ''
      RETURN 0;

    ;WITH Tally (n) AS (
        SELECT TOP (LEN(@input))
            ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
        FROM sys.all_objects
    ),
    Chars AS (
        SELECT 
            SUBSTRING(@input, n, 1) AS ch
        FROM Tally
    )
    SELECT TOP 1 @result = 1
    FROM Chars
    GROUP BY ch
    HAVING COUNT(*) > 1;

    RETURN @result;
END;
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_064_fnHasDuplicateCharacters';
SELECT dbo.fnHasDuplicateCharacters('hlelo') AS HasDuplicates;  -- Returns 1 (true)
SELECT dbo.fnHasDuplicateCharacters('abcd')  AS HasDuplicates;   -- Returns 0 (false)
EXEC test.sp__crt_tst_rtns 'dbo.fnHasDuplicateCharacters';
*/

GO
