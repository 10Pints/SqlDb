SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



-- =================================================================
-- Description: used to import the AttendanceStagingCourseHdr table
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 06-MAR-2025
-- =================================================================
CREATE VIEW [dbo].[ImportAttendanceStagingCourseHdr_vw]
AS
SELECT id, course_nm, section_nm, stage
FROM AttendanceStagingCourseHdr;
/*
SELECT * FROM ImportAttendanceStagingCourseHdr_vw;
*/

GO
