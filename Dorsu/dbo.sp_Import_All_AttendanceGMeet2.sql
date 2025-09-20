SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 01-APR-2025
-- Description:
-- 1: Imports all the GMeet attendance from the supplied folder to the staging tables
-- 2: merges the Attendance data into the Main tables
-- Design:      EA
-- Tests:       
-- =============================================
CREATE PROCEDURE [dbo].[sp_Import_All_AttendanceGMeet2]
    @folder          VARCHAR(500)
   ,@display_tables  BIT = 0
AS
BEGIN
   DECLARE @fn VARCHAR(35)= 'sp_ImportAllFilesInFolder'
   SET NOCOUNT ON;

   EXEC sp_log 1, @fn ,'000: starting:
folder        :[', @folder        ,']
';

-- 1: Import all the GMeet attendance from the supplied folder to the staging tables
   TRUNCATE TABLE AttendanceGMeet2Staging;

   EXEC sp_log 1, @fn ,'010: calling sp_ImportAllFilesInFolder -> AttendanceGMeet2Staging table';
   EXEC sp_Import_All_FilesInFolder
                @folder          = @folder
               ,@table           = 'AttendanceGMeet2Staging'
               ,@view            = 'import_AttendanceGMeet2Staging_vw'
               ,@display_tables  = @display_tables
   ;

   EXEC sp_log 1, @fn ,'020: ret frm sp_ImportAllFilesInFolder chking AttendanceGMeet2Staging pop';
   EXEC sp_assert_tbl_pop 'dbo.AttendanceGMeet2Staging', 'AttendanceGMeet2Staging';

-- 2: merge the Attendance data into the Main tables
   EXEC sp_log 1, @fn ,'030: 2: merge the Attendance data into the Main tables';
   EXEC sp_log 1, @fn ,'999: leaving:';
END
/*
EXEC test.test_021_sp_Import_All_AttendanceGMeet2;
EXEC tSQLt.Run 'test.test_021_sp_Import_All_AttendanceGMeet2';

EXEC tSQLt.RunAll;
*/

GO
