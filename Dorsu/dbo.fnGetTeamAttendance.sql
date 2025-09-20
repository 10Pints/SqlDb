SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =======================================================
-- Author:      Terry Watts
-- Create date: 24-MAY-2025
-- Description: returns the team attendance (all course)
-- Design:      None
-- Tests:       None
-- =======================================================
CREATE FUNCTION [dbo].[fnGetTeamAttendance]( @team_nm VARCHAR(40))
RETURNS @t TABLE
(
    team_nm          VARCHAR(40)
   ,course_nm        VARCHAR(20)
   ,section_nm       VARCHAR(20)
   ,student_id       VARCHAR(9)
   ,student_nm       VARCHAR(50)
   ,is_lead          BIT
   ,attendance_pc    VARCHAR(8)
   ,tot_classes      INT
   ,github_project   VARCHAR(250)
)
AS
BEGIN
   INSERT INTO @t
   (
       team_nm
      ,course_nm
      ,section_nm
      ,student_id
      ,student_nm
      ,is_lead
      ,attendance_pc
      ,tot_classes
      ,github_project
   )
   SELECT
       tm.team_nm
      ,course_nm
      ,tm.section_nm
      ,tm.student_id
      ,tm.student_nm
      ,tm.is_lead
      ,attendance_pc
      ,tot_classes
      ,github_project
   FROM TeamMember_vw tm JOIN AttendanceSummary_vw a ON tm.student_id=a.student_id
   WHERE tm.team_nm LIKE @team_nm;
   RETURN;
END
/*
SELECT * FROM dbo.fnGetTeamAttendance( 'Scatt%');

EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<fn_nm>;
*/

GO
