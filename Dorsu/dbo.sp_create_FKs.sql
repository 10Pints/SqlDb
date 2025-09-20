SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ======================================================
-- Author:        Terry Watts
-- Create date:   25-Feb-2025
-- Description:   re creates all the foreign keys
-- Design:        EA
-- Tests:         test_004_sp_create_FKs
-- Preconditions: none
-- Postconditions:all required relationships created
-- POST01:        returns the count of the created keys
-- ======================================================
CREATE PROCEDURE [dbo].[sp_create_FKs]
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn     VARCHAR(35) = 'sp_create_FKs'
      ,@cnt    INT         = 0
      ,@delta  INT         = 0
   ;

   BEGIN TRY
      EXEC sp_log 1, @fn, '000: starting';

      ------------------------------------------------------------------------------------
      -- 1: Foreign table Attendance: 2 FKs: FK_Attendance_Course, FK_Attendance_Student
      ------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '010: creating FKs for table Attendance';
      EXEC sp_create_FK 'FK_Attendance_ClassSchedule', 'Attendance', 'ClassSchedule', 'classSchedule_id', @cnt = @cnt OUT;
      EXEC sp_create_FK 'FK_Attendance_Student'     , 'Attendance' , 'Student'      , 'student_id', @cnt = @cnt OUT;

      ----------------------------------------------------------------------------------------
      --  Foreign table  Attendance2: 2 FKs: FK_Attendance_Course, FK_Attendance_Student
      ----------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '020: creating FKs for table Attendance2';
      EXEC sp_create_FK 'FK_Attendance2_ClassSchedule', 'Attendance2', 'ClassSchedule', 'classSchedule_id', @cnt = @cnt OUT;
      EXEC sp_create_FK 'FK_Attendance2_Student'      , 'Attendance2', 'Student'      , 'student_id', @cnt = @cnt OUT;

      ---------------------------------------------------------------------------------------------------------------------------------------------
      -- Foreign table ClassSchedule: 4 Fks: FK_ClassSchedule_Course, FK_ClassSchedule_Major, FK_ClassSchedule_Room, FK_ClassSchedule_Section
      ---------------------------------------------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '030: creating FKs for table ClassSchedule';
      EXEC sp_create_FK 'FK_ClassSchedule_Course'     , 'ClassSchedule', 'Course'       , 'course_id',   @cnt = @cnt OUT;
      EXEC sp_create_FK 'FK_ClassSchedule_Major'      , 'ClassSchedule', 'Major'        , 'major_id',    @cnt = @cnt OUT;
      EXEC sp_create_FK 'FK_ClassSchedule_Room'       , 'ClassSchedule', 'Room'         , 'room_id',     @cnt = @cnt OUT;
      EXEC sp_create_FK 'FK_ClassSchedule_Section'    , 'ClassSchedule', 'Section'      , 'section_id',  @cnt = @cnt OUT;

      -----------------------------------------------------------------------------------------------------------------------------------------------------
      -- Foreign table Enrollment 5 Fks: FK_Enrollment_Course, FK_Enrollment_Major, FK_Enrollment_Section, FK_Enrollment_Semester, FK_Enrollment_Student
      -----------------------------------------------------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '040: creating FKs for table Enrollment';
      EXEC sp_create_FK 'FK_Enrollment_Course'  , 'Enrollment', 'Course'  , 'course_id'   , @cnt = @cnt OUT;
      EXEC sp_create_FK 'FK_Enrollment_Major'   , 'Enrollment', 'Major'   , 'major_id'    , @cnt = @cnt OUT;
      EXEC sp_create_FK 'FK_Enrollment_Section' , 'Enrollment', 'Section' , 'section_id'  , @cnt = @cnt OUT;
      EXEC sp_create_FK 'FK_Enrollment_Semester', 'Enrollment', 'Semester', 'semester_id' , @cnt = @cnt OUT;
      EXEC sp_create_FK 'FK_Enrollment_Student' , 'Enrollment', 'Student' , 'student_id'  , @cnt = @cnt OUT;

      ----------------------------------------
      -- Foreign table GoogleAlias
      ----------------------------------------
      --EXEC sp_log 1, @fn, '050: creating keys for  table GoogleAlias';
      --EXEC sp_create_FK 'FK_GoogleAlias_Student', 'GoogleAlias', 'Student', 'student_id';

      --------------------------------------------
      -- Foreign table Team: 1 FK: FK_Team_Event
      --------------------------------------------
      EXEC sp_log 1, @fn, '060: creating keys for table Team';
      EXEC sp_create_FK 'FK_Team_Event' , 'Team', 'Event', 'event_id', @cnt = @cnt OUT;

      --------------------------------------------------------
      -- Foreign table TeamMembers: 1 FK: FK_TeamMembers_Team
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '070: creating keys for table TeamMembers';
      EXEC sp_create_FK 'FK_TeamMembers_Team' , 'TeamMembers', 'Team' , 'team_id', @cnt = @cnt OUT;

      EXEC sp_log 1, @fn, '250: Creating auth table relationships, calling sp_create_FKs_Auth';
      EXEC @delta = sp_create_FKs_Auth;
      SET @cnt = @cnt + @delta;
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, created ', @cnt, ' relationships';
   -- POST01: returns the count of the created keys
   RETURN @cnt;
END
/*
EXEC tSQLt.Run 'test.test_004_sp_create_FKs'
EXEC sp_drop_FKs;
EXEC sp_create_FKs;
*/


GO
