SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Description: Imports the entire schema
-- Design:      
-- Tests:       test_001_sp__import_Schema, test_061_sp__import_Schema
-- Author:      Terry Watts
-- Create date: 25-Feb-2025
-- =============================================
CREATE PROCEDURE [dbo].[sp__import_Schema]
    @root            VARCHAR(500) ='D:\Dorsu\Data'
   ,@display_tables  BIT  = 1
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE 
       @fn           VARCHAR(35)  = 'sp__import_Schema'
      ,@file         VARCHAR(500)
      ,@folder       VARCHAR(500)
      ,@backslash    VARCHAR(2) = CHAR(13) + CHAR(10)
      ;

   EXEC sp_log 1, @fn, '000: starting
@root          :[', @root          , ']
@display_tables:[', @display_tables, ']
';

   BEGIN TRY
      --------------------------------------------------------
      -- Defaults
      --------------------------------------------------------

      --------------------------------------------------------
      -- VALIDATION
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '010: validating';

      --------------------------------------------------------
      -- Process
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '030: process';

      -- Drop all constraints ahead of the data import and clear tables
      -- and clr the table data
      EXEC sp_delete_tbls;

      --------------------------------------------------------
      -- Import Major
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '040: calling sp_Import_Major ',@file;
      EXEC sp_Import_Major @file='Majors.Majors.txt', @folder = @root, @display_tables = @display_tables;

      --------------------------------------------------------
      -- Import Room
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '050: calling sp_Import_Room ',@file;
      EXEC sp_Import_Room @file='Rooms.Rooms.txt', @folder = @root, @display_tables = @display_tables;

      --------------------------------------------------------
      -- Import Course
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '060: calling sp_Import_Course ''Courses.Courses.txt''';
      EXEC sp_Import_Course 
          @file= 'Courses.Courses.txt'
         ,@folder = @root
      ;

      IF @display_tables = 1 SELECT * FROM Course ORDER BY course_nm;

      --------------------------------------------------------
      -- Import Section
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '070: calling sp_Import_Section ', @file;
      EXEC sp_Import_Section @file = 'Sections.Sections.txt', @folder = @root, @display_tables = @display_tables;

      IF @display_tables = 1
         SELECT * FROM Section ORDER BY section_nm;

      ----------------------------------------------------------
      -- ASSERTION:  popd
      ----------------------------------------------------------

      --------------------------------------------------------
      -- Import Students and Enrollments
      --------------------------------------------------------
      SET @folder = CONCAT(@root,'\','Students')
      EXEC sp_log 1, @fn, '080: calling sp_import_All_Enrollments ', @folder;
      EXEC sp_import_All_Enrollments @folder;

      --ALTER TABLE [dbo].[Student] ENABLE TRIGGER [sp_student_insert_trigger];

      --------------------------------------------------------
      -- Import Class schedule - time table data
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '090: calling sp_Import_ClassSchedule';

      EXEC sp_Import_ClassSchedule 
             @file            = 'Class Schedule.Schedule 250317.txt'
            ,@folder          = @root
            ,@display_tables  = @display_tables
            ,@exp_row_cnt     = 19
           ;

      EXEC sp_log 1, @fn, '100: ret frm sp_Import_ClassSchedule';
      SELECT * FROM ClassSchedule;

      --------------------------------------------------------
      -- Import GoogleNames
      --------------------------------------------------------
      SET @folder =  CONCAT(@root,'\','GoogleAliases');
      EXEC sp_log 1, @fn, '110: calling sp_Import_All_GoogleAliases ', @folder;

      EXEC sp_Import_All_GoogleAliases
          @folder          = @folder
         ,@display_tables  = @display_tables

      IF @display_tables = 1
      BEGIN
         SELECT * FROM Student ORDER BY student_nm;
         --SELECT * FROM StudentCourses_vw ORDER BY student_nm;
      END

      --------------------------------------------------------
      --  Import Event
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '120: calling sp_Import_Event ', @file;
      EXEC sp_Import_Event @file = 'Events.Events.txt', @folder = @root, @display_tables = @display_tables;

      --------------------------------------------------------
      --  Import Team
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '130: calling sp_Import_Teams ''Teams.Teams.txt''';
      --EXEC sp_Import_Teams @file = 'Teams.Teams.txt', @folder = 'D:\Dorsu\data', @min_tm_mbr_cnt=1, @max_tm_mbr_cnt= 6, @display_tables = 1;

      EXEC sp_Import_Teams @file = 'Teams.Teams.txt', @folder = 'D:\Dorsu\data', @min_tm_mbr_cnt=1, @max_tm_mbr_cnt= 6, @display_tables = 1;

      --------------------------------------------------------
      --  Import Users Roles Features
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '140: calling sp_ImportAuthUserRoleFeature ', @file;
      EXEC sp_Import_All_AuthUserRoleFeature @folder = @root, @file_mask = '*.txt', @display_tables = @display_tables;

      --------------------------------------------------------
      --  Import Attendance
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '150: importing Attendance, @root: [', @root, '] @mask = Attendance Record Main*.txt';
      EXEC sp_Import_All_Attendance @folder = @root, @mask = 'Attendance Record Main*.txt', @display_tables = @display_tables;

      --------------------------------------------------------
      --  Import GMeet2 Files
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '160: Importing the GMeet2 Files: ';
      SET @folder = CONCAT(@root, '\Attendance\GoogleMeetAttendance\Staging');
      EXEC sp_Import_All_GMeet2FilesInFolder
          @folder         = @folder
         ,@file_mask      = '*.csv'
         ,@display_tables = @display_tables
      ;

      --------------------------------------------------------
      -- Recreate the constraints once all data imported
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '200: recreating constraints';
      EXEC sp_create_FKs;

            --------------------------------------------------------
      -- Chking postconditions
      --------------------------------------------------------
      EXEC sp_ListTables;

      EXEC sp_log 1, @fn, '210: Chking postconditions';
      EXEC sp_assert_tbl_pop 'Attendance';
      EXEC sp_assert_tbl_pop 'AttendanceDates';
      --EXEC sp_assert_tbl_pop 'AttendanceGMeet2';
      EXEC sp_assert_tbl_pop 'AttendanceGMeet2Staging';
      EXEC sp_assert_tbl_pop 'AttendanceGMeet2StagingHdr';
      EXEC sp_assert_tbl_pop '[AttendanceStaging';
      EXEC sp_assert_tbl_pop 'AttendanceStagingColMap';
      EXEC sp_assert_tbl_pop 'AttendanceStagingCourseHdr';
      EXEC sp_assert_tbl_pop 'AttendanceStagingHdr';
      EXEC sp_assert_tbl_pop 'ClassSchedule';
      EXEC sp_assert_tbl_pop 'ClassScheduleStaging';
      EXEC sp_assert_tbl_pop 'Course';
      EXEC sp_assert_tbl_pop 'Enrollment'
      EXEC sp_assert_tbl_pop 'Enrollmentstaging'
      EXEC sp_assert_tbl_pop 'Event';
      EXEC sp_assert_tbl_pop 'Feature';
      EXEC sp_assert_tbl_pop 'GoogleAlias';
      EXEC sp_assert_tbl_pop 'Major';
      EXEC sp_assert_tbl_pop 'Role';
      EXEC sp_assert_tbl_pop 'RoleFeature';
      EXEC sp_assert_tbl_pop 'Room';
      EXEC sp_assert_tbl_pop 'Section';
      EXEC sp_assert_tbl_pop 'Student';
      EXEC sp_assert_tbl_pop 'StudentStaging';
      EXEC sp_assert_tbl_pop 'TeamStaging';           -- *******
      EXEC sp_assert_tbl_pop 'Team';                  -- *******
      EXEC sp_assert_tbl_pop 'TeamMembersStaging';    -- *******
      EXEC sp_assert_tbl_pop 'TeamMembers';           -- *******
      EXEC sp_assert_tbl_pop 'User';
      EXEC sp_assert_tbl_pop 'UserRole';

      --------------------------------------------------------
      -- Optionally display the table
      --------------------------------------------------------
      IF @display_tables = 1
      BEGIN
         SELECT * FROM Major;
         SELECT * FROM Section;
         SELECT * FROM Course;
         SELECT * FROM ClassSchedule;
      END

            --------------------------------------------------------
      -- ASSERTION: completed processing
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '399: completed processing';
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
 --   EXEC sp_create_FKs;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving';
END
/*
EXEC tSQLt.Run 'test_001_sp__import_Schema';
EXEC tSQLt.Run 'test_061_sp__import_Schema';

EXEC sp__import_Schema 'D:\Dorsu\Data', 1;

EXEC tSQLt.RunAll;
*/

GO
