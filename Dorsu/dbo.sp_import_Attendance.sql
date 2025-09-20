SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ======================================================
-- Author:      Terry Watts
-- Create date: 01-MAR-2025
-- Description: Imports the file to AttendanceStaging
--                   then merges to Attendance
-- Design:      EA: Dorsu/Attendance
-- Preconditions the following tables must be populated:
--   Course, ClassSchedule, Section, Enrollment, Student
--
-- Postconditions:
--    POST 01: The attendance tables merged
--    POST 02: returns the count of rows imported, error thrown otherwise
--
-- Tests:       test_014_sp_import_Attendance
--
-- Changes:
-- 250522: Always clear the staging table, dont clear the main here
--         as it is called by sp_import_all_attendance which 
--         can handle that as a 1 off, if you want to clear the 
--         table first do it in the client code
--
-- ======================================================
CREATE PROCEDURE [dbo].[sp_import_Attendance]
    @file            VARCHAR(500)
   ,@folder          VARCHAR(500)= NULL
   ,@sep             CHAR        = 0x09
   ,@codepage        INT         = 65001
   ,@display_tables  BIT         = 0
AS
BEGIN
   SET NOCOUNT ON;

   DECLARE
       @fn VARCHAR(35) = 'sp_import_Attendance'
      ,@row_cnt         INT
   ;

   EXEC sp_log 1, @fn, '000: starting
file  :        [',@file          ,']
folder:        [',@folder        ,']
sep:           [',@sep           ,']
codepage       [',@codepage      ,']
display_tables:[',@display_tables,']
';

   BEGIN TRY
      EXEC sp_log 1, @fn, '005: checking preconditions: tables popd';
      -- Preconditions the following tables must be populated:
      --   Course, ClassSchedule, Enrollment, Section, Student
      EXEC sp_assert_tbl_pop 'Course';
      EXEC sp_assert_tbl_pop 'ClassSchedule';
      EXEC sp_assert_tbl_pop 'Enrollment';
      EXEC sp_assert_tbl_pop 'Section';
      EXEC sp_assert_tbl_pop 'Student';

      EXEC sp_log 1, @fn, '010: truncating table AttendanceStagingDetail';
      TRUNCATE TABLE AttendanceStagingDetail;
      EXEC sp_log 1, @fn, '020: calling sp_Import_AttendanceStaging';

      -- Clean Import the tsv @file into the Attendance staging table:
      -- Then merge the staging table to the main attendance table
      EXEC @row_cnt =
         sp_Import_AttendanceStaging 
            @file           = @file
           ,@folder         = @folder
           ,@clr_first      = 1 -- always clr staging table first -- @clr_first
           ,@display_tables = @display_tables
      ;

      EXEC sp_log 1, @fn, '030: merging tbl Attendance, imported ', @row_cnt,' rows';

      WITH SourceData AS
      (
         SELECT
             a.classSchedule_id
            ,a.student_id
            ,[date]
            ,st_time
            ,present
         FROM
         AttendanceStagingDetail_vw a
      )
      MERGE Attendance AS Target
      USING SourceData AS src
      ON  src.student_id = Target.student_id
      AND src.classSchedule_id = Target.classSchedule_id
      AND src.[date]           = Target.[date]
      -- For Inserts
      WHEN NOT MATCHED BY Target THEN
      INSERT (classSchedule_id    ,     student_id,    [date],     present)
      VALUES (src.classSchedule_id, src.student_id,src.[date], src.present)
      -- For Updates
      WHEN MATCHED THEN 
      UPDATE
      SET
         Target.present	= src.present
      ;

      IF @display_tables = 1
         SELECT * FROM Attendance;

      EXEC sp_log 1, @fn, '499: Completed processing';
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, imported ', @row_cnt,' rows.';
   RETURN @row_cnt;
END
/*
EXEC test.test_014_sp_import_Attendance;

EXEC tSQLt.Run 'test.test_014_sp_importAttendance';
*/

GO
