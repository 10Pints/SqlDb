SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =================================================
-- Description: Returns the normalised name
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 26-MAR-2025
-- =============================================
CREATE FUNCTION [dbo].[fnNormalizeNm](@student_nm VARCHAR(60))
RETURNS VARCHAR(60)
AS
BEGIN
DECLARE 
    --@student_nm VARCHAR(60) = 'Jellian Bungaos'
    @ndx INT
   ,@tmpNm VARCHAR(60)
   ,@i INT
   ;

   SET @ndx = CHARINDEX(' ', @student_nm);

   IF SUBSTRING(@student_nm, @ndx-1, 1)<> ','
   BEGIN
      -- Surname last
      SET @i = dbo.fnFindLastIndexOf(' ', @student_nm);
      SET @student_nm = CONCAT(SUBSTRING(@student_nm, @i+1, 20), ',', SUBSTRING(@student_nm, 1, @i-1));
      --PRINT CONCAT('[', @student_nm, ']');
   END

   RETURN @student_nm;
END
/*
PRINT CONCAT('[', dbo.fnNormalizeNm('Jellian Bungaos'), ']');
PRINT CONCAT('[', dbo.fnNormalizeNm('Pagayawan, Bea Mae M.'), ']');
*/

GO
