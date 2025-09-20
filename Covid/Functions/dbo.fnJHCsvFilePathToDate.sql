SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 24-MAY-2020
-- Description: Converts a file path like '<dir path>\01-22-2020.csv
-- ASSUMING             Date like: MM-DD-YYYY
--
-- PRECONDITIONS: <none>
--
-- POST CONDITIONS:
-- RETURNS:
--    POST 1: Date if possible else NULL
--    POST 2: if file does not end in .csv then NULL
-- =============================================
CREATE FUNCTION [dbo].[fnJHCsvFilePathToDate](@file_path NVARCHAR(500))
RETURNS DATE
AS
BEGIN
DECLARE 
       @file_name       NVARCHAR(260) -- without extension
      ,@import_date     DATE
      ,@n               INT

   -- Validation: POST 1: Date if possible else NULL
   IF ((@file_path IS NULL) OR (LEN(@file_path)=0))
      RETURN NULL;

   -- POST 2: if file does not end in .csv then return NULL
   IF RIGHT(@file_path, 4) <> '.csv'
      RETURN NULL;

   -- ASSERTION: file ends in .csv

   -- Remove extension
   SET @file_name = SUBSTRING(@file_path, 1, LEN(@file_path)-4);

   -- Look for '\' in path
   SET @n = CHARINDEX(NCHAR(92), @file_path);

   IF @n > 0
   BEGIN
      -- ASSERTION: contains a '\'
      SET @file_name = REVERSE(@file_name);

      SET @n   = CHARINDEX(NCHAR(92), @file_name);

      SET @file_name = SUBSTRING(@file_name, 1, @n-1); -- '\'
      SET @file_name = REVERSE(@file_name);
   END

   -- ASSERTION: removed the folders from path - left with file name without ext: 
   -- this should be the date string
   -- Get the date from the file name
   SET @import_date  = [dbo].[fnStringToDate](@file_name);
   RETURN @import_date;
END




GO
