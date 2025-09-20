SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ===============================================================================
-- Description:  deletes the data tables ready for a new import
--               of all the data, resets the auto increment counter
-- Design:       EA
-- Tests:        
-- Author:       
-- Create date:  
--
-- preconditions: none
-- postconditions: POST 01: all data tables crd and and auto incrment coubnters reset to 1
--                 POST 02: all FKs dropped
-- ===============================================================================
CREATE PROCEDURE [dbo].[sp_delete_tbls]
AS
BEGIN
 SET NOCOUNT ON;
   DECLARE 
       @fn     VARCHAR(35) = 'sp_delete_tbls'

   EXEC sp_TruncateTable 'AppLog';
   EXEC sp_log 1, @fn, '000: starting';
   EXEC sp_log 1, @fn, '010: dropping constraints';
   EXEC sp_drop_FKs;

   --EXEC sp_log 1, @fn, '100: truncating table attendance';  -- ok
   --TRUNCATE TABLE Attendance;
   EXEC sp_TruncateTable 'Attendance';

   --EXEC sp_log 1, @fn, '020: truncating table AttendanceStaging'; --ok
   --TRUNCATE TABLE AttendanceStaging;
   EXEC sp_TruncateTable 'AttendanceStaging';

   --EXEC sp_log 1, @fn, '050: truncating table ClassSchedule'; --ok
   --TRUNCATE TABLE ClassSchedule;
   EXEC sp_TruncateTable 'ClassSchedule';

   --EXEC sp_log 1, @fn, '030: truncating table ClassScheduleStaging'; -- ok
   --TRUNCATE TABLE ClassScheduleStaging;
   EXEC sp_TruncateTable 'ClassScheduleStaging';

   --EXEC sp_log 1, @fn, '080: truncating table Course'; -- ok
   --TRUNCATE TABLE Course;
   EXEC sp_TruncateTable 'Course';

   --EXEC sp_log 1, @fn, '070: truncating table CourseSection'; -- ok
   --TRUNCATE TABLE CourseSection;
   --EXEC sp_TruncateTable 'CourseSection';

   --EXEC sp_log 1, @fn, '040: truncating table Enrollment'; --ok
   --TRUNCATE TABLE Enrollment;
   EXEC sp_TruncateTable 'Enrollment';

   --EXEC sp_log 1, @fn, '040: truncating table EnrollmentStaging'; --ok
   --TRUNCATE TABLE EnrollmentStaging;
   EXEC sp_TruncateTable 'EnrollmentStaging';

--    EXEC sp_log 1, @fn, '060: truncating table StudentSection'; -- ok
--    TRUNCATE TABLE StudentSECTION;
   --EXEC sp_log 1, @fn, '090: truncating table Major';  -- ok
   --TRUNCATE TABLE Major;
   EXEC sp_TruncateTable 'Major';

   --EXEC sp_log 1, @fn, '110: truncating table Room'; -- ok
   --TRUNCATE TABLE Room;
   EXEC sp_TruncateTable 'Room';

   --EXEC sp_log 1, @fn, '120: truncating table Section'; -- ok
   --TRUNCATE TABLE Section;
   EXEC sp_TruncateTable 'Section';

   --EXEC sp_log 1, @fn, '130: truncating table Student'; -- ok
   --TRUNCATE TABLE Student;
   EXEC sp_TruncateTable 'Student';

   EXEC sp_log 1, @fn, '200: checking tables not populated';
   EXEC sp_assert_tbl_not_pop 'ClassScheduleStaging', @display_row_cnt=0;
   EXEC sp_assert_tbl_not_pop 'EnrollmentStaging',    @display_row_cnt=0;
   EXEC sp_assert_tbl_not_pop 'AttendanceStaging',    @display_row_cnt=0;
                                                      
   EXEC sp_assert_tbl_not_pop 'ClassSchedule',        @display_row_cnt=0;
   --EXEC sp_assert_tbl_not_pop 'CourseSection';
   --EXEC sp_assert_tbl_not_pop 'StudentSection';

   EXEC sp_assert_tbl_not_pop 'Attendance',           @display_row_cnt=0;
   EXEC sp_assert_tbl_not_pop 'Course',               @display_row_cnt=0;
   EXEC sp_assert_tbl_not_pop 'Major',                @display_row_cnt=0;

   EXEC sp_assert_tbl_not_pop 'Room',                 @display_row_cnt=0;
   EXEC sp_assert_tbl_not_pop 'Section',              @display_row_cnt=0;
   EXEC sp_assert_tbl_not_pop 'Student',              @display_row_cnt=0;

   EXEC sp_log 1, @fn, '999: completed clring tables';
END
/*
EXEC sp_delete_tbls;
SELECT * from DBO.fnGetFksForPrimaryTable('Course')
SELECT * from DBO.fnGetFksForForeignTable('Course')
*/


GO
