SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Function SC: <fn_nm>
-- Description: 
-- EXEC tSQLt.Run 'test.test_<nnn>_<proc_nm>';
-- Design:      
-- Tests:       
-- Author:      
-- Create date: 
-- =============================================
CREATE FUNCTION [dbo].[fnGetScheduleByDay]
(
   @day VARCHAR(10)
)
RETURNS @t TABLE
(
   [day] VARCHAR(10)
   ,st_time	VARCHAR(10)
   ,end_time VARCHAR(10)
   ,course_no VARCHAR(10)
   ,[description] VARCHAR(60)
   ,section VARCHAR(10)
   ,room	VARCHAR(10)
   ,has_projector BIT
   ,building VARCHAR(10)
   ,[floor] int

)
AS
BEGIN
   INSERT INTO @t 
   SELECT TOP 50 * FROM ClassSchedule_vw 
   WHERE [day] = @day
   ORDER BY st_time;

   RETURN;
END
/*
SELECT * FROM dbo.fnGetScheduleByDay('Mon')
*/


GO
