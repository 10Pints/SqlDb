SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==========================================================================
-- Author:       Terry Watts
-- Create date:  5-Apr-2025
-- Description:  Imports the GoogleAlias table from all files in given folder
-- Design:       EA
-- Tests:        
-- Preconditions: All dependent tables have been cleared
-- ==========================================================================
CREATE PROCEDURE [dbo].[sp_Import_All_GoogleAliases]
 @folder          NVARCHAR(MAX)
,@display_tables  BIT = 1
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE 
       @fn        VARCHAR(35) = 'sp_ImportAllGoogleAliases'
      ,@tab       NCHAR(1)=NCHAR(9)
      ,@row_cnt   INT = 0
   ;

   BEGIN TRY
      EXEC sp_log 1, @fn, '000: starting, 
folder        :[',@folder        ,']
display_tables:[',@display_tables,']
';
      EXEC sp_log 1, @fn ,'010: truncating TABLE GoogleNameStaging';
      TRUNCATE TABLE GoogleAlias;

      EXEC sp_log 1, @fn ,'020: calling sp_ImportAllFilesInFolder -> GoogleAlias table';

      EXEC sp_Import_All_FilesInFolder
                @folder          = @folder
               ,@table           = 'GoogleAlias'
--             ,@view            = 'import_AttendanceGMeet2Staging_vw'
               ,@display_tables  = @display_tables
   ;

      IF @display_tables = 1
         SELECT student_id, student_nm, gender, google_alias 
         FROM GoogleAlias
         ORDER BY student_nm;

      EXEC sp_log 1, @fn, '030: updating the Student table google alias field';

      UPDATE Student
      SET google_alias = dbo.fnCamelCase(ga.google_alias)
      FROM GoogleAlias ga JOIN Student s ON ga.student_id = s.student_id

      IF @display_tables = 1
         SELECT * FROM Student WHERE google_alias IS NOT NULL;

      EXEC sp_log 1, @fn, '499: completed processing, file: [',@folder,']';
   END TRY
   BEGIN CATCH
      EXEC sp_log 1, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, imported ', @row_cnt, ' rows from folder: [',@folder,']';
END
/*
EXEC sp_ImportAllGoogleAliases 'D:\Dorsu\Data\GoogleAliases', 1
EXEC tSQLt.Run 'test.';
DELETE FROM GoogleNameAliase WHERE student_id IS NULL;
EXEC sp_Import_GoogleAlias 'D:\Dorsu\Data\GoogleNames.GEC E2 2B.txt', 1, 1;
EXEC sp_Import_GoogleAliase 'D:\Dorsu\Data\GoogleNames.GEC E2 2D.txt', 1, 0;
SELECT * FROM Student;
SELECT * FROM GoogleAlias;
EXEC sp_FindStudent2 '2023-0474';

SELECT Student_id, count(Student_id) 
FROM GoogleAliase
GROUP BY Student_id
ORDER BY count(Student_id) DESC
EXEC test.sp__crt_tst_rtns 'dbo].[sp_ImportAllGoogleAliases'
*/


GO
