SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ======================================================
-- Procedure:   sp_import_attendance
-- Description: Imports the file to AttendanceStaging
--                   then merges to Attendance
-- Design:      EA: Dorsu/Attendance
-- Preconditions the following tables must be populated:
--             Student, Course, Section, Enrollment
--
-- Postconditions: The attendance tables merged 
-- Tests:       test_055_sp_import_All_Attendance
--              test_014_sp_importAttendance
-- Author:      Terry Watts
-- Create date: 07-APR-2025
-- ======================================================
CREATE PROCEDURE [dbo].[sp_import_All_Attendance]
    @folder          VARCHAR(350)
   ,@mask            VARCHAR(50) = NULL
   ,@sep             VARCHAR(50) = NULL
   ,@clr_first       BIT         = 1
   ,@display_tables  BIT = 1
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn        VARCHAR(35) = 'sp_import_All_Attendance'
      ,@file      VARCHAR(100)
      ,@path      VARCHAR(500)
      ,@backslash CHAR(1)     = CHAR(92) --'\';
      ,@row_cnt   INT         = 0
      ,@delta     INT
      ,@file_cnt  INT         = 0

   EXEC sp_log 1, @fn, '000: starting
folder:        [',@folder        ,']
mask:          [',@mask          ,']
sep:           [',@sep           ,']
clr_first:     [',@clr_first     ,']
display_tables:[',@display_tables,']
';

   BEGIN TRY
      --------------------------------------------------------
      -- VALIDATION
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '010: validating';

      --------------------------------------------------------
      -- Defaults
      --------------------------------------------------------
      IF @folder IS NULL
      BEGIN
         SET @folder = 'D:\Dorsu\Data';
         EXEC sp_log 1, @fn, '020: setting the folder to the default: ',@folder;
      END

      -- Create the import file mask
      IF @mask IS NULL SET @mask = '*.txt';
      IF @sep IS NULL  SET @sep  = CHAR(9); -- tab;

      --------------------------------------------------------
      -- Process
      --------------------------------------------------------
       EXEC sp_log 1, @fn, '030: Processing using the following params:
folder:        [',@folder        ,']
mask:          [',@mask          ,']
sep:           [',@sep           ,']
clr_first:     [',@clr_first     ,']
display_tables:[',@display_tables,']
';

       IF @clr_first = 1
         TRUNCATE TABLE Attendance; -- DELETE FROM Attendance;

      -- Get all the file nams in the given folder that match the file mask
       EXEC sp_getFilesInFolder @folder, @mask, @display_tables;

   -----------------------------------------------
   -- ASSERTION: the filenames table is populated
   ----------------------------------------------

      DECLARE FileName_cursor CURSOR FAST_FORWARD FOR
      SELECT [file], [path]
      FROM FileNames;

      -- Open the cursor
      OPEN FileName_cursor;
      EXEC sp_log 1, @fn, '040: B4 import file loop';
      -- Fetch the first row
      FETCH NEXT FROM FileName_cursor INTO @file, @path;

      -- Start processing rows
      WHILE @@FETCH_STATUS = 0
      BEGIN
         -- Process the current row
         SET @file_cnt = @file_cnt +1;
         EXEC sp_log 1, @fn, '050: @file_cnt: ',@file_cnt,' in file loop: calling sp_Import_Enrollment, file: ', @file,  ' @folder: [', @folder, ']  ';


         EXEC @delta = sp_import_Attendance
             @file     = @file
            ,@folder   = @folder
--            ,@clr_first= 0
            ,@sep      = @sep
         ;

         SET @row_cnt = @row_cnt + @delta;

         EXEC sp_log 1, @fn, '060: imported ',@delta, ' rows, @row_cnt: ', @row_cnt;

         -- Fetch the next row
         FETCH NEXT FROM FileName_cursor INTO @file, @path;
      END

            --------------------------------------------------
      -- ASSERTION: completed processing
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '399: completed processing';
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      -- Clean up the cursor
      CLOSE FileName_cursor;
      DEALLOCATE FileName_cursor;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving imported ',@row_cnt, ' rows';
   RETURN @row_cnt;
END
/*
EXEC tSQLt.Run 'test.test_055_sp_import_All_Attendance';

EXEC sp_appLog_display 'sp_import_All_Attendance'
EXEC sp_import_All_Attendance 'D:\Dorsu\Data\Attendance 250529-2030';

SELECT * FROM AttendanceStagingHdr;
SELECT * FROM AttendanceStaging;
SELECT * FROM Attendance;
SELECT * FROM Attendance_vw;
EXEC test.test_014_sp_importAttendance;
EXEC tSQLt.RunAll;
EXEC test.sp__crt_tst_rtns '[dbo].[sp_import_All_Attendance]'
   -- Clean Import the tsv @file into the Attendance staging table:
   -- Then merge the staging table to the main attendance table
   --EXEC sp_ImportAttendanceStaging @file, @display_tables; --, @course_nm, @section_nm;

*/

GO
