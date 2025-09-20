SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =================================================================
-- Description: used to import the ImportAttendanceStagingHdr table
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 06-MAR-2025
-- =================================================================
CREATE view [dbo].[ImportAttendanceStagingHdr_vw]
AS
SELECT *
FROM AttendanceStagingHdr;
/*
SELECT * FROM ImportAttendanceStagingHdr_vw;
*/

GO
