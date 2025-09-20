SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


--====================================================================================
-- Author:      Terry Watts
-- Create date: 23-Mar-2025
-- Description: Displays the attendance for all students
-- Attendance   is references the ClassSchedule to define the course, section,class
-- Attendance   further defines the student
-- Design: EA
-- Tests:
--====================================================================================
CREATE VIEW [dbo].[AttendanceStaging_vw]
AS
SELECT
    [index]
   ,student_id
   ,student_nm
   ,a.course_nm
   ,a.section_nm AS a_section_nm
   ,sec.section_nm AS sec_section_nm
   ,csv.classSchedule_id
   ,attendance_percent
   ,c.course_id
   ,sec.section_id
--   ,st_time
   ,time24
   ,stage
   ,cm.ordinal
   ,cm.dt as [date]
   ,value as present
FROM
          AttendanceStaging a CROSS APPLY string_split(a.stage, NCHAR(9),1)
LEFT JOIN AttendanceStagingColMap cm  ON a.  [index]    = cm.ordinal
LEFT JOIN Course                  c   ON c.  course_nm  = a.course_nm
LEFT JOIN Section                 sec ON sec.section_nm = a.section_nm
LEFT JOIN ClassSchedule_vw        csv ON csv.classSchedule_id=cm. schedule_id AND csv.[day] = dbo.fnGetDayfromDate(dt)
--WHERE value <> '-'
;
/*
SELECT * FROM AttendanceStaging_vw;
SELECT * FROM AttendanceStaging;
SELECT * FROM AttendanceStagingColMap;
SELECT * FROM AttendanceStagingCourseHdr;
SELECT * FROM ClassSchedule_vw;

SELECT TOP 100 * FROM Enrollment WHERE student_id = '2020-1309';
SELECT TOP 100 * FROM Enrollment_vw WHERE student_id = '2020-1309';
SELECT * FROM Attendance_vw WHERE student_id = '2023-1772'
SELECT TOP 100 * FROM Enrollment_vw WHERE student_id = '2023-1772';
*/

GO
