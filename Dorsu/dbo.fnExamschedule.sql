SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==========================================================
-- Description: returns the team details for the parameters
-- Design:      EA
-- Tests:       test_030_sp_GetTeams
-- hrsw is based on the class duartion
-- Author:      Terry Watts
-- Create date: 5-APR-2025
-- ==========================================================
CREATE FUNCTION [dbo].[fnExamschedule]
(
    @days         VARCHAR(6)
   ,@st           VARCHAR(4)
)
RETURNS @t TABLE
(
    [days]        VARCHAR(4)
   ,st            VARCHAR(4)
   ,[end]         VARCHAR(4)
   ,ex_date       VARCHAR(20)
   ,ex_day        VARCHAR(20)
   ,duaration     VARCHAR(4)
)
AS
BEGIN
   INSERT INTO @t
(
    [days]
   ,st
   ,[end]
   ,ex_date
   ,ex_day
   ,duaration
)
SELECT [days], st, [end], ex_date, ex_day, FORMAT((CONVERT(INT, [end]) - CONVERT(INT, st))*2.0/100,'0.00')
FROM ExamSchedule_vw
WHERE (st = @st OR @st IS NULL)
AND ( [days] = @days OR @days  IS NULL)
ORDER BY 
[days], st;

   RETURN;
END
/*
SELECT * FROM dbo.fnExamschedule('MWF', '1500');
SELECT * FROM dbo.fnExamschedule('TTH', NULL);
SELECT * FROM dbo.fnExamschedule(NULL, NULL);
SELECT * FROM ExamSchedule_vw;
EXEC tSQLt.Run 'test.test_030_sp_GetTeams';
TTH	1030	1200	May 21	Wednesday	3.40
TTH	0730	0900	May 20	Tuesday	3.40
*/


GO
