SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


--====================================================================================
-- Author:       Terry Watts
-- Create date:  10-May-2025
-- Description:  used to control teh import fields
-- Design:       EA
-- Tests:
--====================================================================================
CREATE VIEW [dbo].[ImportClassScheduleStaging_vw]
AS
SELECT
      id,
      course_nm,
      major_nm,
      section_nm,
      [day],
      times,
      room_nm
FROM
     ClassScheduleStaging
;
/*
SELECT * FROM ImportClassScheduleStaging_vw;
*/

GO
