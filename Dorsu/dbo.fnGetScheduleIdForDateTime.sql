SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==========================================================
-- Author:      Terry Watts
-- Create date: 10-MAY-2025
-- Description: Returns the schedule id for given date, time
-- Tests:       test_058_fnGetScheuleIdForDateTime
-- ==========================================================
CREATE FUNCTION [dbo].[fnGetScheduleIdForDateTime]
(
    @dt     DATE
   ,@time24 VARCHAR(4)
)
RETURNS INT
AS
BEGIN
DECLARE
   @schedule_id  INT = -1
  ,@dow          INT
  ,@day_nm       VARCHAR(10)
  ,@start_time   VARCHAR(4)
;

SET @day_nm     = dbo.fnGetDayfromDate(@dt)--FORMAT(@dt    , 'ddd');
SET @start_time = SUBSTRING(@time24, 1,2);
SET @dow = dbo.fnGetDowFromDayName(@day_nm);

SELECT @schedule_id = classSchedule_id
FROM ClassSchedule
WHERE [day] = @day_nm
AND st_time  <=@time24
AND end_time >@time24
;

   RETURN @schedule_id;
END
/*
EXEC test.test_058_fnGetScheduleIdForDateTime;
EXEC tSQLt.Run 'test.test_058_fnGetScheduleIdForDateTime';

PRINT dbo.fnGetScheuleIdForDateTime('2025-04-10', '0800');

SELECT * FROM classSchedule;
*/

GO
