SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

--====================================================================================
-- Author:       Terry Watts
-- Create date:  02-May-2025
-- Description:  Displays the student attendance
-- Attendance_vw references the ClassSchedule to define the course, section,class
-- Attendance_vw further defines the student
-- Design:       EA
-- Tests:
--====================================================================================
CREATE VIEW [dbo].[Attendance_vw]
AS
SELECT
    a.student_id
   ,s.student_nm
   ,course_nm
   ,sec.section_nm
   ,st_time
   ,a.[date]
   ,present
   ,csv.classSchedule_id
   ,course_id
   ,sec.section_id
FROM
     Attendance a 
JOIN ClassSchedule_vw csv ON csv.classSchedule_id = a.classSchedule_id
LEFT JOIN Student     s   ON s  .student_id       = a.student_id
LEFT JOIN Section     sec ON sec.section_nm       = csv.section_nm
;
/*
SELECT * FROM Attendance_vw;
SELECT * FROM ClassSchedule_vw;
SELECT * FROM AttendanceStagingColMap;
SELECT * FROM AttendanceStaging;
SELECT * FROM AttendanceStagingCourseHdr;

SELECT TOP 100 * FROM Enrollment WHERE student_id = '2020-1309';
SELECT TOP 100 * FROM Enrollment_vw WHERE student_id = '2020-1309';
SELECT * FROM Attendance_vw WHERE student_id = '2023-1772'
SELECT TOP 100 * FROM Enrollment_vw WHERE student_id = '2023-1772';
*/

GO
