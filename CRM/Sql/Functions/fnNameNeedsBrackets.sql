-- ========================================================
-- Author:      Terry Watts
-- Create date: 06-SEP-2025
-- Description: returns 1 if name needs brackets.
--    i.e. is a reserver word or has some wierd characters
-- Design:      
-- Tests:       
-- ========================================================
CREATE FUNCTION dbo.fnNameNeedsBrackets(@name VARCHAR(60))
RETURNS BIT
AS
BEGIN
   DECLARE
    @v BIT = 0
   ,@c CHAR
   ;

   SET @c = iif(dbo.fnLen(@name)> 0, SUBSTRING(@name, 1, 1), NULL);
   SET @v = CASE
   WHEN dbo.fnIsReservedWord(@name)= 1 THEN 1
   --WHEN @name LIKE '%[ --+*$&@{}()-+=~|`'']%' THEN 1
   WHEN @name LIKE '%[ *&=~`]%' THEN 1
   WHEN @name IS NULL      THEN 1
   WHEN @name LIKE '%[!@#$-]%' THEN 1
   WHEN @name = ''         THEN 1
   WHEN CHARINDEX('%',@name) > 0         THEN 1
   WHEN CHARINDEX('^',@name) > 0         THEN 1
   WHEN CHARINDEX('(',@name) > 0         THEN 1
   WHEN CHARINDEX(')',@name) > 0         THEN 1
   WHEN CHARINDEX('+',@name) > 0         THEN 1
   WHEN CHARINDEX('|',@name) > 0         THEN 1
   WHEN CHARINDEX('\\',@name) > 0         THEN 1
   WHEN CHARINDEX('/',@name) > 0         THEN 1
   WHEN CHARINDEX('?',@name) > 0         THEN 1
   WHEN @c IS NOT NULL AND @c LIKE '[0123456789]' THEN 1 -- leading charcter cannot be numeric
   ELSE 0
   END;

   RETURN @v;
END
/*
EXEC tSQLt.Run 'test.test_077_fnNameNeedsBrackets';

EXEC tSQLt.RunAll;
PRINT dbo.fnIsReservedWord('a');
*/
