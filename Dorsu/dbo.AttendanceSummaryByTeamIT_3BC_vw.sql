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
CREATE VIEW [dbo].[AttendanceSummaryByTeamIT_3BC_vw]
AS
SELECT TOP 1000
    team_nm
   ,FORMAT(att, '00.00%') AS mean_attendance
   ,section_nm
FROM
(
SELECT
       team_nm
      ,section_nm
      ,att
FROM AttendanceSummaryByTeam_vw
WHERE section_nm in ('IT 3B', 'IT 3C')
) X
ORDER BY att DESC;
/*
SELECT * FROM AttendanceSummaryByTeamIT_3BC_vw;
SELECT * FROM AttendanceSummaryByTeam_vw;
*/

GO
