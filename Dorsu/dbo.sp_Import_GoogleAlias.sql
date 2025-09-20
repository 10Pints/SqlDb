SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ============================================================
-- Description:  Imports theGoogleNameStaging table from a tsv
-- Design:       EA
-- Tests:        test_031_sp_Import_GoogleAlias
-- Author:       Terry watts
-- Create date:  2-Apr-2025
-- Preconditions: All dependent tables have been cleared
-- ============================================================
CREATE PROCEDURE [dbo].[sp_Import_GoogleAlias]
    @file            NVARCHAR(MAX)
   ,@folder          VARCHAR(500)= NULL
   ,@clr_first       BIT         = 1
   ,@sep             CHAR        = 0x09
   ,@codepage        INT         = 65001
   ,@display_tables  BIT         = 0
AS
BEGIN
   SET NOCOUNT ON;

   DECLARE 
       @fn        VARCHAR(35) = 'sp_Import_GoogleAlias'
      ,@tab       NCHAR(1)=NCHAR(9)
      ,@row_cnt   INT = 0
   ;

   EXEC sp_log 1, @fn, '000: starting calling sp_import_txt_file
file:          [',@file          ,']
folder:        [',@folder        ,']
clr_first:     [',@clr_first     ,']
sep:           [',@sep           ,']
codepage:      [',@codepage      ,']
display_tables:[',@display_tables,']
';

   BEGIN TRY
      ----------------------------------------------------------------
      -- Validate preconditions, parameters
      ----------------------------------------------------------------

      ----------------------------------------------------------------
      -- Setup
      ----------------------------------------------------------------

      ----------------------------------------------------------------
      -- Import text file
      ----------------------------------------------------------------
      EXEC @row_cnt = sp_import_txt_file 
          @table           = 'GoogleAlias'
         ,@file            = @file
         ,@folder          = @folder
         ,@field_terminator= @sep
         ,@codepage        = @codepage
         ,@clr_first       = @clr_first
         ,@display_table   = @display_tables
      ;
      EXEC sp_log 1, @fn, '010: imported ', @row_cnt,  ' rows';

      -- Camelcase
      UPDATE GoogleAlias SET google_alias = dbo.fnCamelCase(google_alias);

      EXEC sp_log 1, @fn, '020: updating the Student table';

      UPDATE Student
      SET google_alias = ga.google_alias
      FROM GoogleAlias ga JOIN Student s ON ga.student_id = s.student_id

      EXEC sp_log 1, @fn, '499: completed processing, file: [',@file,']';
   END TRY
   BEGIN CATCH
      EXEC sp_log 1, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, imported ', @row_cnt, ' rows from file: [',@file,']';
END
/*
EXEC test.test_031_sp_Import_GoogleAlias;

EXEC tSQLt.Run 'test.test_031_sp_Import_GoogleNameStaging';
DELETE FROM GoogleAlias WHERE student_id IS NULL;
EXEC sp_Import_GoogleAlias 'D:\Dorsu\Data\GoogleNames.GEC E2 2B.txt', 1, 1;
EXEC sp_Import_GoogleAlias 'D:\Dorsu\Data\GoogleNames.GEC E2 2D.txt', 1, 0;
SELECT * FROM Student;
EXEC sp_FindStudent2 '2023-0474';

SELECT Student_id, count(Student_id) 
FROM GoogleAlias
GROUP BY Student_id
ORDER BY count(Student_id) DESC


EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<proc_nm>';
*/


GO
