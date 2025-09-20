SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 18-DEC-2019
-- Description: case sensitive compare helper function
-- Returns:     1 if match false 0
-- =============================================
CREATE FUNCTION [dbo].[fnCaseSensistiveCompare]
(
       @expected        NVARCHAR(100)
      ,@actual          NVARCHAR(100)
)
RETURNS BIT
AS
BEGIN
   DECLARE
       @exp             VARBINARY(40)
      ,@act             VARBINARY(40)
      ,@res             bit  = 0
      ,@exp_is_null     bit  = 0
      ,@act_is_null     bit  = 0

   IF (@expected IS NULL)
      SET @exp_is_null = 1;

   IF (@actual IS NULL)
      SET @act_is_null = 1;

   IF (@exp_is_null = 1) AND (@act_is_null = 1)
      RETURN 1;

   IF ( dbo.fnLEN(@expected) = 0) AND ( dbo.fnLEN(@actual) = 0)
      RETURN 1;

   SET @exp = CONVERT(VARBINARY(250), @expected);
   SET @act = CONVERT(VARBINARY(250), @actual);

   IF (@exp = 0x) AND (@act = 0x)
   BEGIN
      SET @res = 1;
   END
   ELSE
   BEGIN
      IF @exp = @act
         SET @res = 1;
      ELSE
         SET @res = 0;
   END

   -- ASSERTION @res is never NULL
   RETURN @res;
END

GO
