SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


CREATE   view [dbo].[timetable_vw]
AS
SELECT st_time as [start], end_time as [end],
iif(Mon is null, '', CONCAT(course_nm, ' sec: ',Mon, ', rm: ', room_nm)) AS Monday,
iif(Tue is null, '', CONCAT(course_nm, ' sec: ',Tue, ', rm: ', room_nm)) AS Tuesday,
iif(Wed is null, '', CONCAT(course_nm, ' sec: ',Wed, ', rm: ', room_nm)) AS Wednesday,
iif(Thu is null, '', CONCAT(course_nm, ' sec: ',Thu, ', rm: ', room_nm)) AS Thursday,
iif(Fri is null, '', CONCAT(course_nm, ' sec: ',Fri, ', rm: ', room_nm)) AS Friday
FROM
(
  SELECT --iif(Mon is null, '', CONCAT(course_nm, ' sec: ',Mon, ', rm: ', room_nm)) AS Monday,
  st_time, end_time, course_nm, section_nm, [day], room_nm, 6 as ndx
  FROM ClassSchedule_vw
) as sourcetable
pivot
(
MAX(/*section_nm*/ndx) for [day] in ([Mon],[Tue],[Wed],[Thu],[Fri])
) AS PVTl;
/*
SELECT * FROM timetable_vw;
SELECT * FROM ClassSchedule_vw
SELECT * FROM ClassScheduleStaging
SELECT * FROM ClassSchedule
SELECT * FROM section
*/

GO
