SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


--====================================================================================
-- Author:       Terry Watts
-- Create date:  28-May-2025
-- Description:  Displays the student attendance summary
-- Attendance_vw references the ClassSchedule to define the course, section,class
-- Attendance_vw further defines the student
-- Design:       EA
-- Tests:
--====================================================================================
CREATE VIEW [dbo].[AttendanceSummaryByTeam_vw]
AS
SELECT TOP 1000 team_nm, mean_attendance, section_nm, att
FROM
(
SELECT
       tm.team_nm
      ,tm.section_nm
      ,FORMAT(avg(attendance), '00.00%') as mean_attendance, avg(attendance) as att
FROM TeamMember_vw tm JOIN AttendanceSummary_vw a ON tm.student_id=a.student_id
--WHERE tm.section_nm in ('IT 3B', 'IT 3C')
GROUP BY tm.section_nm, tm.team_nm
) X
ORDER BY att DESC;
;
/*
SELECT * FROM AttendanceSummaryByTeam_vw WHERE section_nm in ('IT 3B')
*/

GO
