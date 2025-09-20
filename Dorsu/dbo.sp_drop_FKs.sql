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
CREATE PROCEDURE [dbo].[sp_drop_FKs]
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
      -- 1: Foreign table Attendance: 2 FKs: FK_Attendance_ClassSchedule, FK_Attendance_Student
      ------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '010: dropping keys for table Attendance';
      EXEC sp_drop_FK 'FK_Attendance_ClassSchedule';
      EXEC sp_drop_FK 'FK_Attendance_Student';

      ----------------------------------------------------------------------------------------
      --  Foreign table  Attendance2: 2 FKs: FK_Attendance_Course, FK_Attendance_Student
      ----------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '020: dropping keys for table Attendance2';
      EXEC sp_drop_FK 'FK_Attendance2_ClassSchedule';
      EXEC sp_drop_FK 'FK_Attendance2_Student';

      ---------------------------------------------------------------------------------------------------------------------------------------------
      -- Foreign table ClassSchedule: 4 Fks: FK_ClassSchedule_Major, FK_ClassSchedule_Room, FK_ClassSchedule_Section
      ---------------------------------------------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '030: dropping keys for table Attendance';
      EXEC sp_drop_FK 'FK_ClassSchedule_Course';
      EXEC sp_drop_FK 'FK_ClassSchedule_Major';
      EXEC sp_drop_FK 'FK_ClassSchedule_Room';
      EXEC sp_drop_FK 'FK_ClassSchedule_Section';

      -----------------------------------------------------------------------------------------------------------------------------------------------------
      -- Foreign table Enrollment 5 Fks: FK_Enrollment_Course, FK_Enrollment_Major, FK_Enrollment_Section, FK_Enrollment_Semester, FK_Enrollment_Student
      -----------------------------------------------------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '040: dropping FKs for table Enrollment';
      EXEC sp_drop_FK 'FK_Enrollment_Course';
      EXEC sp_drop_FK 'FK_Enrollment_Major';
      EXEC sp_drop_FK 'FK_Enrollment_Section';
      EXEC sp_drop_FK 'FK_Enrollment_Semester';
      EXEC sp_drop_FK 'FK_Enrollment_Student';

      ----------------------------------------
      -- Foreign table GoogleAlias
      ----------------------------------------
      EXEC sp_log 1, @fn, '050: dropping keys for Primary table GoogleName';
      EXEC sp_drop_FK 'FK_GoogleAlias_Student';

      ----------------------------------------
      -- Foreign table Team
      ----------------------------------------
      EXEC sp_log 1, @fn, '060: dropping keys for table Team';
      EXEC sp_drop_FK 'FK_Team_Event';

      ----------------------------------------
      -- Foreign table TeamMembers
      ----------------------------------------
      EXEC sp_log 1, @fn, '070: dropping keys for table TeamMembers';
      EXEC sp_drop_FK 'FK_TeamMembers_Team';

      ----------------------------------------
      -- Role tables
      ----------------------------------------
      EXEC sp_log 1, @fn, '80: Dropping auth table relationships, calling sp_drop_FKs_Auth';
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
