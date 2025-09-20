SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================================
-- Author:      Terry Watts
-- Create date: 11-MAY-2025
-- Description: displays the AttendanceStagingColMap
-- =============================================================
CREATE VIEW [dbo].[AttendanceStagingColMap_vw]
AS
SELECT TOP 10000 
ordinal, dt, time24, [day], st_time, end_time, schedule_id, dow
FROM
     AttendanceStagingColMap cm
LEFT JOIN Schedule_vw s ON cm.schedule_id =s.classSchedule_id
ORDER BY dt,st_time;
/*
SELECT * FROM AttendanceStagingColMap_vw;
*/


GO
