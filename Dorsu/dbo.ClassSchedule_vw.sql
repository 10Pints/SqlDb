SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


CREATE VIEW [dbo].[ClassSchedule_vw] AS
SELECT TOP 1000
    classSchedule_id
   ,[day]
   ,st_time
   ,end_time
   ,course_nm
   ,c.[description]
   ,section_nm
   ,r.room_nm
   ,has_projector
   ,building
   ,[floor]
   ,c.course_id
   ,s.section_id
FROM ClassSchedule cs 
LEFT JOIN Course  c ON c.course_id  = cs.course_id
LEFT JOIN section s ON s.section_id = cs.section_id
LEFT JOIN Room    r ON cs.room_id   = r.room_id
ORDER BY dow, st_time;
/*
SELECT * FROM ClassSchedule;
SELECT * FROM ClassSchedule_vw;
*/

GO
