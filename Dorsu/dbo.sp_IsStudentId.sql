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
CREATE proc [dbo].[sp_IsStudentId] @v VARCHAR(20)
--RETURNS BIT
AS
BEGIN
   DECLARE
       @fn     VARCHAR(35)    = N'sp_IsStudentId'
      ,@s      VARCHAR(1000)
      ,@a      VARCHAR(5)
      ,@b      VARCHAR(5)
      ,@ret    INT            = 0
      ,@n      INT
   ;

      EXEC sp_log 1, @fn ,' starting
@V    :[', @v    ,']
';

   WHILE 1=1
   BEGIN
      -- Check the length
      SET @n = dbo.fnLen(@v);
      IF @n <> 9 -- returns 0 bad length
      BEGIN
         EXEC sp_log 1, @fn, 'Len(@v) <> 9: [',@n,']';
         BREAK;
      END

      -- Check contains a - in pos 5
      IF SUBSTRING(@v, 5,1) <> '-'
      BEGIN
         EXEC sp_log 1, @fn, 'SUBSTRING(@v, 5,1) <> ''-''';
         BREAK;
      END

      -- Check both parts are ints
      SELECT 
          @a = schema_nm
         ,@b = rtn_nm
      FROM dbo.fnSplitQualifiedName(@v)
      ;

      IF dbo.fnIsInt(@a) = 0
      BEGIN
         EXEC sp_log 1, @fn, 'part 1 [', @a, '] is not int'
         BREAK;
      END

      IF dbo.fnIsInt(@b) = 0
      BEGIN
         EXEC sp_log 1, @fn, 'part 2  [', @b, '] is not int'
         BREAK;
      END

      SET @ret = 1;
      BREAK;
   END

   EXEC sp_log 1, @fn ,' leaving ret: ', @ret ;
   RETURN @ret;
END
/*
EXEC tSQLt.Run 'test.test_035_fnIsStudentId';
EXEC tSQLt.RunAll;
EXEC test.sp__crt_tst_rtns '[dbo].[fnIsStudentId]';
*/

GO
