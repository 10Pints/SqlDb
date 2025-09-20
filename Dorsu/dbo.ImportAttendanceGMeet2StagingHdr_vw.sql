SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==========================================================================
-- Description: used to import the ImportAttendanceGMeet2StagingHdr_vw table
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 24-APR-2025
-- ==========================================================================
CREATE VIEW [dbo].[ImportAttendanceGMeet2StagingHdr_vw]
AS
SELECT 
   id
FROM AttendanceGMeet2StagingHdr;
/*
SELECT * FROM ImportAttendanceGMeet2StagingHdr_vw;
*/

GO
