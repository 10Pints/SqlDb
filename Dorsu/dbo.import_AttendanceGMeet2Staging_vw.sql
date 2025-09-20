SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


--=====================================================================
-- Author:      Terry Watts
-- Create date: 23-Mar-2025
-- Description: Displays the attendance for all students
--
-- Design: EA
-- Tests:
--=====================================================================
CREATE VIEW [dbo].[import_AttendanceGMeet2Staging_vw]
AS
SELECT
    s_no, google_alias, meet_st, Joined, [stopped], duration, gmeet_id
FROM
     AttendanceGMeet2Staging
/*
SELECT * FROM import_AttendanceGMeet2Staging_vw;
*/

GO
