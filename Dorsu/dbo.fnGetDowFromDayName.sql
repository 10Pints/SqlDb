SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =======================================================================
-- Author:      Terry Watts
-- Create date: 08-MAY-2025
-- Description: maps the short day name like 
--             like {MON, Tue, WEd, THU, FRI,SAT, SUN}
--             to   {1,2,3,4,5,6,7}
-- Design:      NONE
-- Tests:       test_053_GetDayfromDate
-- =======================================================================
CREATE FUNCTION [dbo].[fnGetDowFromDayName](@ShortDayName VARCHAR(3))
RETURNS VARCHAR(3)
AS
BEGIN
   RETURN CASE @ShortDayName
        WHEN 'Mon'       THEN 1
        WHEN 'Tue'       THEN 2
        WHEN 'Wed'       THEN 3
        WHEN 'Thu'       THEN 4
        WHEN 'Fri'       THEN 5
        WHEN 'Sat'       THEN 6
        WHEN 'Sun'       THEN 7
        WHEN 'Monday'    THEN 1
        WHEN 'Tuesday'   THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday'  THEN 4
        WHEN 'Friday'    THEN 5
        WHEN 'Saturday'  THEN 6
        WHEN 'Sunday'    THEN 7
        ELSE -1
    END ;
END
/*
EXEC tSQLt.RunAll;
EXEC test.sp__crt_tst_rtns '[dbo].[GetDowFromDayName]';
*/

GO
