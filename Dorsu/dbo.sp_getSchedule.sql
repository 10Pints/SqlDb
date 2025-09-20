SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 05-05-2025
-- Description: 
-- Design:      
-- Tests:       
-- =============================================
CREATE PROCEDURE [dbo].[sp_getSchedule]
    @course_nm  VARCHAR(20) = NULL
   ,@major_nm   VARCHAR(10) = NULL
   ,@day        VARCHAR(3)  = NULL
AS
BEGIN
   SELECT * FROM dbo.fnGetSchedule(@course_nm, @major_nm, @day);
END
/*
EXEC sp_getSchedule NULL, 'BSIT', NULL
EXEC sp_getSchedule  NULL, 'BSIT';
EXEC sp_getSchedule  @major_nm='BSIT';

EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<proc_nm>';
*/

GO
