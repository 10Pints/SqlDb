SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

--====================================================================================
-- Author:      Terry Watts
-- Create date: 11-May-2025
-- Description: Displays the Attendance Staging Detail
-- Attendance   is references the ClassSchedule to define the course, section,class
-- Attendance   further defines the student
-- Design: EA
-- Tests:
--====================================================================================
CREATE VIEW [dbo].[AttendanceStagingDetail_vw]
AS
SELECT
     id
    ,student_id
    ,ordinal
    ,present
    ,cs.[day]
    ,[date]
    ,cs.classSchedule_id
    ,asd.schedule_id AS asd_schedule_id
    ,course_nm
    ,section_nm
    ,st_time
    ,end_time
FROM
   AttendanceStagingDetail asd
   LEFT JOIN ClassSchedule_vw cs ON asd.schedule_id = cs.classSchedule_id
;
/*
SELECT * FROM AttendanceStagingDetail_vw
where section_nm = '2B';
SELECT * FROM AttendanceStagingDetail;
SELECT * FROM ClassSchedule;
SELECT * FROM ClassSchedule_vw;
SELECT * FROM AttendanceStagingDetail asd JOIN ClassSchedule_vw cs ON asd.schedule_id = cs.classSchedule_id;

student_id, ordinal, present, date, schedule_id, classSchedule_id, course_id, major_id, section_id, day, st_time, end_time, dow, description, room_id
*/

GO
