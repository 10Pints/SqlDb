SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==============================================================================
-- Description:   Imports the EnrollmentStaging table from a tsv
-- Design:        EA
-- Tests:         
-- Author:        Terry Watts
-- Create date:   23-Feb-2025
-- Preconditions: FKs dropped, Stuent table clrd if necessary
-- Postconditions:
-- POST 01: inmported the import file successfully and returns the number of rows imnported
--          error otherwise
-- ==============================================================================
CREATE PROCEDURE [dbo].[sp_Import_Enrollment]
    @file            VARCHAR(500)
   ,@folder          VARCHAR(500)= NULL
   ,@clr_first       BIT         = 1
   ,@sep             CHAR        = 0x09
   ,@codepage        INT         = 65001
   ,@display_tables  BIT         = 0
AS
BEGIN
   SET NOCOUNT ON;

   DECLARE
    @fn        VARCHAR(35) = 'sp_Import_Enrollment'
   ,@tab       NCHAR(1)=NCHAR(9)
   ,@row_cnt   INT
   ,@tot_cnt   INT

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
      -- Import text file to EnrollmentStaging tbl clr first
      ----------------------------------------------------------------
      EXEC @row_cnt = sp_import_txt_file
          @table           = 'EnrollmentStaging'
         ,@file            = @file
         ,@folder          = @folder
         ,@field_terminator= @sep
         ,@codepage        = @codepage
         ,@clr_first       = 1 -- @clr_first
         ,@display_table   = @display_tables
      ;

      SELECT @tot_cnt = Count(*) FROM EnrollmentStaging;
      EXEC sp_log 1, @fn, '010: calling sp_fixup_EnrollmentStaging';
      EXEC sp_fixup_EnrollmentStaging;

      --Do not TRUNCATE TABLE Student;

      EXEC sp_log 1, @fn, '020: merge student table with basic data: student_id, student_nm, gender';

      WITH SourceData AS
      (
         SELECT student_id, student_nm, course_id, s.section_id, m.major_id, gender
         FROM EnrollmentStaging es
         LEFT JOIN Course  c ON es.course_nm  = c.course_nm
         LEFT JOIN Section s ON es.section_nm = s.section_nm
         LEFT JOIN Major   m ON es.major_nm   = m.major_nm
      )
      MERGE Student as Target
      USING SourceData AS SRC 
      ON  SRC.student_id = Target.student_id
      WHEN NOT MATCHED BY Target THEN
      INSERT (    student_id,     student_nm, section_id    ,     gender)
      VALUES (SRC.student_id, SRC.student_nm, SRC.section_id, SRC.gender)
      WHEN  MATCHED THEN 
      UPDATE SET 
          section_id = SRC.section_id
         ,gender     = SRC.gender
      ;


      -- Pop Enrollment
      --TRUNCATE TABLE Enrollment;
      WITH SourceData AS
      (
         SELECT student_id, course_id, s.section_id, m.major_id
         FROM EnrollmentStaging es
         LEFT JOIN Course  c ON es.course_nm  = c.course_nm
         LEFT JOIN Section s ON es.section_nm = s.section_nm
         LEFT JOIN Major   m ON es.major_nm   = m.major_nm
      )
      MERGE Enrollment AS Target --(student_id, course_id, section_id, major_id)
      USING SourceData AS SRC
      ON  SRC.student_id = Target.student_id
      AND SRC.course_id  = Target.course_id
      WHEN NOT MATCHED BY Target THEN
      INSERT (student_id, course_id, section_id, major_id)
      VALUES (student_id, course_id, section_id, major_id)
      ;

   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving imported ',@row_cnt, ' rows, StudentCourseStaging table now has ', @tot_cnt, ' rows';
   RETURN @row_cnt;
END
/*
EXEC tSQLt.Run 'test.test_000_sp_importAllStudents';
EXEC test.test_000_sp_importAllStudents;
EXEC sp_importAllStudents;

EXEC sp_drop_fks;
TRUNCATE TABLE Student
EXEC sp_Import_StudentCourse 'Students.250224.GEC E2 2B.txt','D:\Dorsu\Data';
EXEC sp_create_fks;

SELECT * FROM StudentCourseStaging;
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<proc_nm>';
SELECT * FROM Student;
SELECT * FROM EnrollmentStaging;
*/

GO
