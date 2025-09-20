SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 17-MAY-2025
-- Description: CamelCase seps = {<spc>, ' -}
--=============================================
CREATE FUNCTION [dbo].[fnFindNthOccurrence]
(
    @input VARCHAR(8000),
    @char CHAR(1),
    @n INT)
RETURNS INT
AS
BEGIN
    DECLARE @position INT = 0;
    DECLARE @count INT = 0;
    DECLARE @result INT = 0;
    
    WHILE @count < @n AND @position < LEN(@input)
    BEGIN
        SET @position = @position + 1;
        IF SUBSTRING(@input, @position, 1) = @char
        BEGIN
            SET @count = @count + 1;
            IF @count = @n
                SET @result = @position;
        END
    END
    
    RETURN @result;
END
/*
SELECT dbo.fnFindNthOccurrence('a,b,c,d,e,f', ',', 3);
*/

GO
