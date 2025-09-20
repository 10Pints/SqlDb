SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Description: Displays the Course section info
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 06-MAR-2025
-- =============================================
CREATE view [dbo].[ImportAttendanceStaging_vw]
AS
SELECT 
    [index]
   ,student_id
   ,student_nm
   ,attendance_percent
   ,stage
FROM AttendanceStaging;
/*
SELECT * FROM ImportAttendanceStaging_vw;
SELECT * FROM AttendanceStaging;

EXEC test.test_056_sp_Import_AttendanceStaging;
*/

GO
