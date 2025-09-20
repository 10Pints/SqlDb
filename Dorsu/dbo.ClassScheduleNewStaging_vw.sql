SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO




CREATE view [dbo].[ClassScheduleNewStaging_vw]
AS
   WITH CTE AS
   (
   SELECT TOP 1000 A.course_id, a.description, a.major_nm, a.section_nm, a.day, a.st_time, a.ordinal
   FROM 
      (
      SELECT
       course_id
      ,[description]
      ,major_nm
      ,section_nm
      ,[day].value as [day]
      ,st_time.value AS st_time
      ,st_time.ordinal

      ,day_num = 
         CASE
            WHEN [day].value= 'Mon' THEN 1
            WHEN [day].value= 'Tue' THEN 2
            WHEN [day].value= 'Wed' THEN 3
            WHEN [day].value= 'Thu' THEN 4
            WHEN [day].value= 'Fri' THEN 5
            WHEN [day].value= 'Sat' THEN 6
            WHEN [day].value= 'Sun' THEN 7
        END
   FROM ClassScheduleNewStaging c
   CROSS Apply string_split([days], ',') as [day]
   CROSS Apply string_split(times,  ',', 1) as st_time
   ) A
   )
   SELECT cte.course_id, cte.day, cte.description, cte.major_nm, cte.section_nm, ordinal--, room
   FROM cte 
   JOIN 
   (
      SELECT
       course_id
      ,[description]
      ,major_nm
      ,section_nm
      ,[days].value as [day]
      ,rooms.value as room
      FROM
      ClassScheduleNewStaging css 
      CROSS Apply string_split([days], ',') as [days]
      CROSS Apply string_split(rooms,  ',') as rooms
   )   x ON cte.course_id=X.course_id AND cte.section_nm = X.section_nm AND cte.day = X.day --AND X.
;


GO
