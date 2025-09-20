SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =====================================================================================
-- Description: Populates the student table from the EnrollmentStagings table
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 22-Feb-2025
--
-- Preconditions:
--    PRE01: The relevant FKs have been dropped
--    PRE02: Section table pop     (chkd) 
--    PRE03: EnrollmentStaging pop (chkd) 
--
-- Postconditions: the following table are populated:
--    StudentStaging
--    Student
-- =====================================================================================
CREATE PROCEDURE [dbo].[sp_pop_students] @display_tables BIT = 0
AS
BEGIN
   SET NOCOUNT OFF;
   DECLARE @fn VARCHAR(35) = 'sp_pop_students'

   BEGIN TRY
      EXEC sp_log 1, @fn, '000: starting, validation';

      -----------------------------------------------------------
      -- Validation
      -----------------------------------------------------------

      -- PRE02: (chkd) Section table pop
      EXEC sp_assert_tbl_pop 'Section';
      -- PRE03: EnrollmentStaging pop (chkd) 
      EXEC sp_assert_tbl_pop 'EnrollmentStaging';
      EXEC sp_assert_tbl_pop 'Enrollment';

      -----------------------------------------------------------
      -- Process
      -----------------------------------------------------------
      EXEC sp_log 1, @fn, '010: process, truncating tables Student, StudentStaging';
      TRUNCATE TABLE Student;
      TRUNCATE TABLE StudentStaging;

      --EXEC sp_create_FKs;

      EXEC sp_log 1, @fn, '020: pop the StudentStaging table';

      -- Pop StudentStaging table from the Enrollment Staging table
      INSERT INTO StudentStaging(student_id, student_nm, gender)
      SELECT DISTINCT student_id, student_nm, gender
      FROM EnrollmentStaging
      ORDER BY student_nm;
      EXEC sp_log 1, @fn, '030: populated the StudentStaging table: with ', @@ROWCOUNT, ' rows';

      IF @display_tables = 1 SELECT * FROM StudentStaging order by student_nm;
      EXEC sp_assert_tbl_pop 'StudentStaging';

      EXEC sp_log 1, @fn, '040: populating the Student table';
      INSERT INTO Student(student_id, student_nm,gender)
      SELECT student_id, student_nm, gender
      FROM StudentStaging
      ORDER BY student_nm;
      EXEC sp_log 1, @fn, '050: populated the Student table: with ', @@ROWCOUNT, ' rows';

      IF @display_tables = 1 SELECT * FROM Student order by student_nm;
      EXEC sp_assert_tbl_pop 'Student';

      EXEC sp_log 1, @fn, '070: populated the StudentCourse table: with ', @@ROWCOUNT, ' rows';
      EXEC sp_log 1, @fn, '400: completed processing';
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      EXEC sp_create_FKs;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving: OK';
END
/*
EXEC sp_drop_fks;
EXEC sp_pop_students 1;
EXEC sp_create_fks;

SELECT * FROM Student
SELECT * FROM Section
SELECT * from StudentCourseStaging
Where student_id = '2018-0429';
*/


GO
