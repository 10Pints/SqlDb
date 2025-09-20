SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ====================================================================
-- Author:      Terry Watts
-- Create date: 11-APR-2025
-- Description: determines if @s is in DORSU student id fmt 
--
-- Changes:
-- ====================================================================
CREATE FUNCTION [dbo].[fnIsStudentId](@v VARCHAR(20))
RETURNS BIT
AS
BEGIN
   DECLARE
       @s  VARCHAR(1000)
      ,@a  VARCHAR(5)
      ,@b  VARCHAR(5)
   ;

   -- Check the length
   IF dbo.fnLen(@v) <> 9 -- returns 0 bad length
      RETURN 0;

   -- Check contains a - in pos 5
   IF SUBSTRING(@v, 5,1) <> '-'
      RETURN 0;

   -- Check both parts are ints
   SELECT 
       @a = a
      ,@b = b
   FROM dbo.fnSplitPair2(@v, '-')
   ;

   IF dbo.fnIsInt(@a) = 0
      RETURN 0;

   IF dbo.fnIsInt(@b) = 0
      RETURN 0;

   RETURN 1;
END
/*
PRINT dbo.fnIsStudentId('1998-2005')
a	b
1998	2005

EXEC tSQLt.Run 'test.test_035_fnIsStudentId';
EXEC tSQLt.RunAll;
SELECT * FROM dbo.fnSplitPair2('1998-2005', '-')
   ;
   SELECT dbo.fnIsInt('1998')
   SELECT dbo.fnIsInt('2005')
*/

GO
