SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =========================================================================
-- Author:      Terry Watts
-- Create date: 29-MAY-2020
-- Description: process the staging file and handles "
-- replace the commas inside of sub strings"" with a special character
-- =========================================================================
CREATE FUNCTION [dbo].[fnProcessStageImport](@staging NVARCHAR(4000))
RETURNS NVARCHAR(4000)
AS
BEGIN
   DECLARE
       @sub       NVARCHAR(4000)
      ,@staging2  NVARCHAR(4000)
      ,@first     NVARCHAR(4000) = NULL
      ,@last      NVARCHAR(4000) = NULL
      ,@TAB       NVARCHAR(1)    = NCHAR(9)
      ,@pos1      INT            = 1
      ,@pos2      INT            = NULL
      ,@len       INT            = Len(@staging)

   SET @staging2 = @staging;

   WHILE @pos1 < @len
   BEGIN
      SET @pos1 = CHARINDEX('"', @staging2, @pos1);

      IF @pos1 = 0
         BREAK; -- DONE

      SET @pos2 = CHARINDEX('"', @staging2, @pos1+1);
      -- We have quoted txt starting at pos 1 ending at pos 2
      SET @sub = SUBSTRING( @staging2, @pos1+1, @pos2-@pos1-+1);
      -- replace the inner commas with a special character that we can replace later say a tab
      -- first part is the part before the replacement
      -- this can be null
      SET @sub = REPLACE(@sub, ',', @TAB);

      if @pos1 > 1
         SET @first = SUBSTRING( @staging2, 1, @pos1-1);

      -- last part is the part after the replacement
      -- this can be null
      if @pos2<@len
         SET @last = SUBSTRING( @staging2, @pos2+1, @len-@pos2);

      SET @staging2   = CONCAT(@first, @sub, @last);
      SET @pos1       = @pos2+1;
   END

   RETURN @staging2;
END





GO
