SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =====================================================
-- Author:        Terry Watts
-- Create date:   25-Feb-2025
-- Description:   drops all foreign keys
-- Design:        EA
-- Tests:         test_004_sp_create_FKs
-- Preconditions: none
-- Postconditions:
-- POST01:        returns the count of the dropped keys
-- =====================================================
CREATE PROCEDURE [dbo].[sp_drop_FKs_old]
AS
BEGIN
 SET NOCOUNT ON;
   DECLARE
       @fn     VARCHAR(35) = 'sp_drop_FKs'
      ,@cnt    INT         = 0
      ,@delta  INT         = 0
   ;

   BEGIN TRY
      EXEC sp_log 1, @fn, '000: starting';

      ------------------------------------------------------------------------------------
      -- 1: Foreign table Attendance: 2 FKs: FK_Attendance_Course, FK_Attendance_Student
      ------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '005: dropping keys for Referenced table Attendance';
      EXEC sp_log 1, @fn, '010: dropping constraint Attendance.FK_Attendance_Student';

      IF dbo.FkExists('FK_Attendance_Student') = 1
      BEGIN
         EXEC sp_log 1, @fn, '015: dropping constraint Attendance.FK_Attendance_Student';
         ALTER TABLE Attendance DROP CONSTRAINT FK_Attendance_Student;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '020: constraint Attendance.FK_Attendance_Student does not exist';

      EXEC sp_log 1, @fn, '010: dropping constraint Attendance.FK_Attendance_ClassSchedule';

      IF dbo.FkExists('FK_Attendance_ClassSchedule') = 1
      BEGIN
         EXEC sp_log 1, @fn, '015: dropping constraint Attendance.FK_Attendance_ClassSchedule';
         ALTER TABLE Attendance DROP CONSTRAINT FK_Attendance_ClassSchedule;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '020: constraint Attendance.FK_Attendance_ClassSchedule does not exist';

      ----------------------------------------
      --  Foreign table  Attendance2: 2 FKs: FK_Attendance_Enrollment, FK_Attendance2_Student
      ----------------------------------------
      EXEC sp_log 1, @fn, '005: dropping keys for Referenced table Attendance2';
      EXEC sp_log 1, @fn, '010: dropping constraint Attendance2.FK_Attendance_Enrollment';

      IF dbo.FkExists('FK_Attendance2_Student') = 1
      BEGIN
         EXEC sp_log 1, @fn, '015: dropping constraint Attendance2.FK_Attendance2_Student';
         ALTER TABLE Attendance2 DROP CONSTRAINT FK_Attendance2_Student;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '020: constraint Attendance2.FK_Attendance2_Student does not exist';

      EXEC sp_log 1, @fn, '010: dropping constraint Attendance2.FK_Attendanc2_ClassSchedule';

      IF dbo.FkExists('FK_Attendance2_ClassSchedule') = 1
      BEGIN
         EXEC sp_log 1, @fn, '015: dropping constraint Attendance2.FK_Attendanc2_ClassSchedule';
         ALTER TABLE Attendance2 DROP CONSTRAINT FK_Attendance2_ClassSchedule;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '020: constraint Attendance2.FK_Attendanc2_ClassSchedule does not exist';

      ----------------------------------------
      -- Foreign table ClassSchedule 4 FKs: Major, Room, Course, Section
      ----------------------------------------
      EXEC sp_log 1, @fn, '025: dropping keys for Referenced table Attendance';
      IF dbo.FkExists('FK_ClassSchedule_Major') = 1
      BEGIN
         EXEC sp_log 1, @fn, '030: dropping constraint ClassSchedule.FK_ClassSchedule_Major';
         ALTER TABLE ClassSchedule DROP CONSTRAINT FK_ClassSchedule_Major;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '035: constraint ClassSchedule.FK_ClassSchedule_Major does not exist';

      IF dbo.FkExists('FK_ClassSchedule_Room') = 1
      BEGIN
         EXEC sp_log 1, @fn, '040: dropping constraint ClassSchedule.FK_ClassSchedule_Room';
         ALTER TABLE ClassSchedule DROP CONSTRAINT FK_ClassSchedule_Room;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '045: constraint ClassSchedule.FK_ClassSchedule_Section does not exist';

      EXEC sp_log 1, @fn, '050: FK_ClassSchedule_Course';
      IF dbo.FkExists('FK_ClassSchedule_Course') = 1
      BEGIN
         EXEC sp_log 1, @fn, '055: dropping constraint ClassSchedule.FK_ClassSchedule_Course';
         ALTER TABLE ClassSchedule DROP CONSTRAINT FK_ClassSchedule_Course;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '060: constraint ClassSchedule.FK_ClassSchedule_Course does not exist';

      EXEC sp_log 1, @fn, '050: FK_ClassSchedule_Section';
      IF dbo.FkExists('FK_ClassSchedule_Section') = 1
      BEGIN
         EXEC sp_log 1, @fn, '055: dropping constraint ClassSchedule.FK_ClassSchedule_Section';
         ALTER TABLE ClassSchedule DROP CONSTRAINT FK_ClassSchedule_Section;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '060: constraint ClassSchedule.FK_ClassSchedule_Section does not exist';

      EXEC sp_log 1, @fn, '065: dropping keys for Primary table Course';

      EXEC sp_log 1, @fn, '070: FK_ClassSchedule_Course';
      IF dbo.FkExists('FK_ClassSchedule_Course') = 1
      BEGIN
         EXEC sp_log 1, @fn, '075: dropping constraint ClassSchedule.FK_ClassSchedule_Course';
         ALTER TABLE ClassSchedule DROP CONSTRAINT FK_ClassSchedule_Course;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '080: constraint ClassSchedule.FK_ClassSchedule_Course does not exist';

      EXEC sp_log 1, @fn, '085: dropping keys for Primary table Room';
      EXEC sp_log 1, @fn, '090: FK_ClassSchedule_room';

      IF dbo.FkExists('FK_ClassSchedule_room') = 1
      BEGIN
         EXEC sp_log 1, @fn, '095: dropping constraint ClassSchedule.FK_ClassSchedule_room';
         ALTER TABLE ClassSchedule DROP CONSTRAINT FK_ClassSchedule_room;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '100: constraint ClassSchedule.FK_ClassSchedule_room does not exist';

      ----------------------------------------
      -- Foreign table CourseSection
      ----------------------------------------
      EXEC sp_log 1, @fn, '105: dropping keys for Referenced table CourseSectiont';
      IF dbo.FkExists('FK_CourseSection_Course') = 1
      BEGIN
         EXEC sp_log 1, @fn, '110: dropping constraint StudentSection.FK_CourseSection_Course';
         ALTER TABLE CourseSection DROP CONSTRAINT FK_CourseSection_Course;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '115: constraint CourseSection.FK_CourseSection_Course does not exist';

      IF dbo.FkExists('FK_CourseSection_Section') = 1
      BEGIN
         EXEC sp_log 1, @fn, '120: dropping constraint CourseSection.FK_CourseSection_Section';
         ALTER TABLE CourseSection DROP CONSTRAINT FK_CourseSection_Section;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '125: constraint StudentCourse.FK_CourseSection_Section does not exist';

      ----------------------------------------
      -- Foreign table: Enrollment
      ----------------------------------------
      EXEC sp_log 1, @fn, '130: dropping keys for Referenced table Enrollment';
      IF dbo.FkExists('FK_Enrollment_Course') = 1
      BEGIN
         EXEC sp_log 1, @fn, '135: dropping constraint FK_Enrollment_Course';
         ALTER TABLE Enrollment DROP CONSTRAINT FK_Enrollment_Course;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '140: constraint FK_Enrollment_Course does not exist';

      IF dbo.FkExists('FK_Enrollment_Major') = 1
      BEGIN
         EXEC sp_log 1, @fn, '145: dropping constraint FK_Enrollment_Major';
         ALTER TABLE Enrollment DROP CONSTRAINT FK_Enrollment_Major;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '150: constraint FK_Enrollment_Major does not exist';

      IF dbo.FkExists('FK_Enrollment_Student') = 1
      BEGIN
         EXEC sp_log 1, @fn, '155: dropping constraint FK_Enrollment_Student';
         ALTER TABLE Enrollment DROP CONSTRAINT FK_Enrollment_Student;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '160: constraint FK_Enrollment_Student does not exist';

      IF dbo.FkExists('FK_Enrollment_Section') = 1
      BEGIN
         EXEC sp_log 1, @fn, '165: dropping constraint FK_Enrollment_Section';
         ALTER TABLE Enrollment DROP CONSTRAINT FK_Enrollment_Section;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '170: constraint FK_Enrollment_Section does not exist';

      IF dbo.FkExists('FK_Enrollment_Semester') = 1
      BEGIN
         EXEC sp_log 1, @fn, '175: dropping constraint FK_Enrollment_Semester';
         ALTER TABLE Enrollment DROP CONSTRAINT FK_Enrollment_Semester
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '180: constraint FK_Enrollment_Semester does not exist';

      ----------------------------------------
      -- Foreign table StudentCourse
      ----------------------------------------
      EXEC sp_log 1, @fn, '185: dropping keys for Referenced table StudentCourse';
      IF dbo.FkExists('FK_StudentCourse_Section') = 1
      BEGIN
         EXEC sp_log 1, @fn, '190: dropping constraint StudentCourse.FK_StudentCourse_Section';
         ALTER TABLE StudentCourse DROP CONSTRAINT FK_StudentCourse_Section;
         SET @cnt = @cnt + 1;
      END
         EXEC sp_log 1, @fn, '195: constraint StudentCourse.FK_StudentCourse_Section does not exist';

      ----------------------------------------
      -- Foreign table StudentSection
      ----------------------------------------
      EXEC sp_log 1, @fn, '200: dropping keys for Primary table StudentSection';
      IF dbo.FkExists('FK_StudentSection_Student') = 1
      BEGIN
         EXEC sp_log 1, @fn, '205: dropping constraint FK_StudentSection_Student';
         ALTER TABLE [dbo].StudentSection DROP CONSTRAINT FK_StudentSection_Student;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '210: constraint FK_StudentCourse_Student does not exist';

      ----------------------------------------
      -- Foreign table GoogleName
      ----------------------------------------
      EXEC sp_log 1, @fn, '215: dropping keys for Primary table GoogleName';
      IF dbo.FkExists('FK_GoogleName_Student') = 1
      BEGIN
         ALTER TABLE GoogleName DROP CONSTRAINT FK_GoogleName_Student;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '220: constraint FK_GoogleName_Student does not exist';

      ----------------------------------------
      -- Foreign table Team
      ----------------------------------------
      EXEC sp_log 1, @fn, '225: dropping keys for table Team';
      IF dbo.FkExists('FK_Team_Event') = 1
      BEGIN
         EXEC sp_log 1, @fn, '230: dropping constraint Team.FK_Team_Event';
         ALTER TABLE Team DROP CONSTRAINT FK_Team_Event;

         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '235: constraint Team.FK_Team_Event does not exist';


      ----------------------------------------
      -- Foreign table TeamMembers
      ----------------------------------------
      EXEC sp_log 1, @fn, '240: dropping keys for table TeamMembers';
      IF dbo.FkExists('FK_TeamMembers_Team') = 1
      BEGIN
         EXEC sp_log 1, @fn, '245: dropping constraint TeamMembers.FK_TeamMembers_Team';
         ALTER TABLE TeamMembers DROP CONSTRAINT FK_TeamMembers_Team;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '250: constraint TeamMembers.FK_TeamMembers_Team does not exist';

      EXEC sp_log 1, @fn, '250: Dropping auth table relationships, calling sp_drop_FKs_Auth';
      EXEC @delta = sp_drop_FKs_Auth;
      SET @cnt = @cnt + @delta;
         /*
      ----------------------------------------
      -- Test tables
      ----------------------------------------
      ----------------------------------------
      -- Foreign table test.test_005_F
      ----------------------------------------
      IF dbo.FkExists('FK_test_005_F_test_005_P') = 1
      BEGIN
         EXEC sp_log 1, @fn, '255: dropping constraint FK_StudentSection_Student';
         ALTER TABLE test.test_005_F DROP CONSTRAINT FK_test_005_F_test_005_P;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '260: constraint FFK_test_005_F_test_005_P does not exist';
*/
      ------------------------
      -- Completed processing
      ------------------------
      EXEC sp_log 1, @fn, '498: dropped all necessary constraints';
      EXEC sp_log 1, @fn, '499: completed processing';
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving: dropped ', @cnt, ' relationships';
-- POST01:        returns the count of the dropped keys
   RETURN @cnt;
END
/*
EXEC tSQLt.Run 'test.test_004_sp_create_FKs';
EXEC tSQL.RunAll;

EXEC sp_drop_FKs;
EXEC sp_create_FKs;
*/

GO
