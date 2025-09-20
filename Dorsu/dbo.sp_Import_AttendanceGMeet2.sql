SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =================================================================================
-- Author:         Terry Watts
-- Create date:    17-Mar-2025
-- Description:    Imports the Attendance 2 staging table from a tsv
-- Design:         EA
-- Tests:          test_019_sp_ImportAttendanceGMeet2
-- Preconditions:  if @one_off = 0 AttendanceGMeet2StagingHdr must be popd
-- Postconditions: POST 01: AttendanceGMeet2 tbl populated
--                 POST 02L: if @one_off = 0 teh tAttendanceGMeet2 tbl popd
--
-- Parameters:
-- @@file_path: file path of the file imported
-- @one_off   : flag used to define wheter this import is a single import or 
--              part of many, in which case neither the hdr or merge need be handled here
-- Process:
-- User: Record the GMeet using the tracker
-- User: Close the GMeet session to save the report
-- User: Download the saved report as a csv
-- User: Add a 2 row header to the csv 
-- Sys:  Import the file using the GMeet attendance Tracker Import
-- Sys:  Import the header to the header table
-- Sys:  Import the attendance data to the AttendanceGMeet2Staging table
-- Sys:  Merge it and the header info to the main AttendanceGMeet2 table
-- =================================================================================
CREATE PROCEDURE [dbo].[sp_Import_AttendanceGMeet2]
       @file            NVARCHAR(MAX)
      ,@folder          NVARCHAR(MAX) = NULL
      ,@one_off         BIT = 1 --  -- flag to signal to clr first and do merge after
      ,@display_tables  BIT = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn              VARCHAR(35) = 'sp_ImportAttendanceGMeet2'
      ,@row_cnt         INT
      ,@course_nm       NVARCHAR(20)
      ,@section_nm      NVARCHAR(20)
      ,@class_date      DATE
      ,@class_st_time   TIME
      ,@file_path       NVARCHAR(MAX)

   BEGIN TRY
      EXEC sp_log 1, @fn, '000: starting
file          :[',@file     ,']
folder        :[',@folder     ,']
one_off       :[',@one_off       ,']
display_tables:[',@display_tables,']
';

      IF @one_off = 1
      BEGIN
         EXEC sp_log 1, @fn, '005: truncating table AttendanceGMeet2';
         TRUNCATE TABLE AttendanceGMeet2;
      END

      SET @file_path = IIF( @folder IS NOT NULL, CONCAT(@folder, CHAR(92), @file ), @file);

   -- Sys: Import the file using the GMeet attendance Tracker Import
   -- Sys: Import the header to the header table
      EXEC sp_log 1, @fn, '010: Importing the AttendanceGMeet2StagingHdr table, file: ',@file_path;
      EXEC sp_import_txt_file
          @table           = 'AttendanceGMeet2StagingHdr'
         ,@file            = @file_path
         ,@field_terminator = ','
         ,@row_terminator   = '0x0a'
         ,@first_row       = 2
         ,@last_row        = 2
         ,@clr_first       = 1
         ,@display_table   = @display_tables
         ,@exp_row_cnt     = 1                     -- Make sure only 1 row
      ;

      -------------------------------------------------------------------
      -- ASSERTION got the header row
      -------------------------------------------------------------------
      EXEC sp_log 1, @fn, '020: ASSERTION: Imported 1 row into AttendanceGMeet2StagingHdr table';

      -- Set the meta data from the hdr row/tbl
      SELECT
          @class_date    = [date]
         ,@class_st_time = cls_st
         ,@course_nm     = course_nm
         ,@section_nm    = section_nm
      FROM AttendanceGMeet2StagingHdr
      ;

      -- Sys: Import the attendance data to the AttendanceGMeet2Staging table
      EXEC sp_log 1, @fn, '030: Importing the AttendanceGMeet2Staging table, file: ',@file_path;

      EXEC @row_cnt = sp_import_txt_file
          @table            = 'AttendanceGMeet2Staging'
         ,@file             = @file_path
         ,@field_terminator = ','
         ,@row_terminator   = '0x0a'
         ,@first_row        = 5
         ,@clr_first        = @one_off -- in this scenario clear the table first
         ,@view            = 'import_AttendanceGMeet2Staging_vw'
         ,@display_table    = 0--@display_tables
         ,@expect_rows      = 1
      ;

      -- Fixup AttendanceGMeet2Staging
      EXEC sp_log 1, @fn, '040: performing fixup; calling sp_fixup_AttendanceGMeet2Staging'
      EXEC sp_fixup_AttendanceGMeet2Staging;

      -------------------------------------------------------------------
      -- Sys:  Merge the header info to the main AttendanceGMeet2 table
      -------------------------------------------------------------------
      IF @one_off = 1 -- in this scenario do the merge now
      BEGIN
         EXEC sp_log 1, @fn ,'050: merge calling sp_merge_AttendanceGMeet2';
         EXEC sp_merge_AttendanceGMeet2;
         EXEC sp_log 1, @fn ,'060: merge completed';
      END
      -------------------------------------------------------------------
      -- Postconditions:
      -------------------------------------------------------------------

      EXEC sp_log 1, @fn, '300: checking Postconditions';
      EXEC sp_log 1, @fn, '310: chking POST 01: AttendanceGMeet2Staging populated';
      EXEC sp_assert_tbl_pop 'AttendanceGMeet2Staging';
      EXEC sp_log 1, @fn, '100: Completed processing';

      IF @display_tables = 1
      BEGIN
         SELECT * FROM AttendanceGMeet2Staging;
         SELECT * FROM AttendanceGMeet2;
      END
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      SELECT 'sp_ImportAttendanceGMeet2 Caught exception';

      IF @display_tables = 1
      BEGIN
         SELECT * FROM AttendanceGMeet2Staging;
         SELECT * FROM AttendanceGMeet2;
      END

      ;THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving imported ',@row_cnt, ' rows';
END
/*
DELETE FROM AttendanceGMeet2;
-- SELECT * FROM AttendanceGMeet2;
EXEC test.test_019_sp_ImportAttendanceGMeet2;

EXEC sp_ImportAttendanceGMeet2Staging 'D:\Dorsu\Data\Attendance Record.GEC E2 2D.txt'
*/

GO
