-- =============================================
-- Author:      Terry Watts
-- Create date: 5-SEP-2025
-- Description: 
-- Design:      
-- Tests:       
-- =============================================
CREATE FUNCTION [dbo].[fnIsValidTableColumnName]
(
   @field_nm VARCHAR(128)
)
RETURNS BIT
AS
BEGIN
   DECLARE
       @IsValid   BIT = 0
   ;

   WHILE 1=1
   BEGIN
      -- Rule 1: Check if empty or null
      -- Rule 1: Check if empty or null
       IF @field_nm IS NULL OR LTRIM(RTRIM(@field_nm)) = ''
       BEGIN
         --SET @IsValid = 2;
         BREAK;
      END

       -- Rule 2: Check length (max 128 chars)
       IF LEN(@field_nm) > 128
       BEGIN
         --SET @IsValid = 3;
         BREAK;
      END

       -- Rule 3: Check if starts with letter or underscore
       IF @field_nm NOT LIKE '[a-zA-Z_]%'
       BEGIN
         --SET @IsValid = 4;
         BREAK;
      END

       -- Rule 4: Check for invalid characters (allow letters, digits, underscore only)
       IF @field_nm LIKE '%[^a-zA-Z0-9_]%'
       BEGIN
         --SET @IsValid = 5;
         BREAK;
      END

      -- Rule 5: Check if the name is a reserved word or requires escaping
      -- QUOTENAME will wrap invalid/reserved names in brackets; compare to original
      IF dbo.fnIsReservedWord(@field_nm) = 1
       BEGIN
         --SET @IsValid = 6;
         BREAK;
      END

      -- finally is true
      SET @IsValid = 1;
      BREAK;
   END

   RETURN @IsValid;
END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<fn_nm>;
EXEC test.sp__crt_tst_rtns 'dbo.fnIsValidTableColumnName';
*/
