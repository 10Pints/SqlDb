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
CREATE view [dbo].[ImportGMeetAttendanceStaging_vw]
AS
SELECT line
FROM AttendanceGMeetStaging
/*
SELECT * FROM ImportGMeetAttendanceStaging_vw;
*/

GO
