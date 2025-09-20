SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



--====================================================================================
-- Author:       Terry Watts
-- Create date:  24-May-2025
-- Description:  Displays the student attendance summary
-- Attendance_vw references the ClassSchedule to define the course, section,class
-- Attendance_vw further defines the student
-- Design:       EA
-- Tests:
--====================================================================================
CREATE VIEW [dbo].[AttendanceSummary_vw]
AS
SELECT TOP 1000
student_id, student_nm, is_lead, team_nm, section_nm, course_nm, FORMAT(attendance, '00.00%') as attendance_pc, tot_classes, att, attendance
FROM
(
   SELECT
       X.student_id
      ,X.student_nm
      ,is_lead
      ,X.section_nm
      ,course_nm
      ,tmv.team_nm
      ,tot_classes
      ,att
      ,att/tot_classes AS attendance
   FROM
   (
      SELECT
          student_id
         ,student_nm
         ,course_nm
         ,section_nm
         ,CAST(count(*) AS FLOAT)      AS tot_classes
         ,SUM(CAST(present AS FLOAT))  AS att
      FROM Attendance_vw 
      GROUP BY course_nm, section_nm, student_id, student_nm
   ) X
   LEFT JOIN TeamMember_vw tmv ON X.student_id = tmv.student_id
)Y
ORDER BY Section_nm, team_nm, is_lead DESC, student_nm
;
/*
SELECT * FROM AttendanceSummary_vw
WHERE section_nm IN ('IT 3B','IT 3C')
ORDER BY att DESC, student_nm, course_nm;

SELECT * FROM Attendance_vw;
*/

GO
