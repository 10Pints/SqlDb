SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =========================================================
-- Description: Imports G Meet attendance
--
-- Notes: Will truncate table ClassSchedule
-- Design:         EA
-- Tests:          
-- Author:         Terry Watts
-- Create date:    14-Mar-2025
-- Preconditions:  None
-- Postconditions: AttendanceGMeetStaging populated
-- =========================================================
CREATE PROCEDURE [dbo].[sp_Import_GMeetAttendance]
    @file            NVARCHAR(MAX)
   ,@folder          VARCHAR(500)= NULL
   ,@date            DATE
   ,@class_start     INT -- 24 hr clock time like 0830
   ,@course_nm       NVARCHAR(20)
   ,@section_nm      NVARCHAR(20)
   ,@clr_first       BIT         = 1
   ,@sep             CHAR        = 0x09
   ,@codepage        INT         = 65001
   ,@display_tables  BIT         = 1
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn              VARCHAR(35) = 'sp_ImportGMeetAttendance'
      ,@tab_str         NCHAR(5)    = iif(@sep = 0x09, '<TAB>', ',')
      ,@row_cnt         INT         = 0
      ,@class_start_str VARCHAR(4)
   ;

   BEGIN TRY
      EXEC sp_log 1, @fn, '000: starting,
file:          [',@file          ,']
folder:        [',@folder        ,']
clr_first:     [',@clr_first     ,']
sep:           [',@sep           ,']
codepage:      [',@codepage      ,']
date:          [',@date          ,']
class_start:   [',@class_start   ,']
course_nm:     [',@course_nm     ,']
section_nm:    [',@section_nm    ,']
display_tables:[',@display_tables,']
';

      --------------------------------------------------------------
      -- Validation
      --------------------------------------------------------------
      EXEC sp_log 1, @fn, '010: validation';

      ----------------------------------------------------------------
      -- Setup
      ----------------------------------------------------------------
      TRUNCATE TABLE AttendanceGMeetStaging;
      TRUNCATE TABLE AttendanceGMeet;

      --------------------------------------------------------------
      -- Process
      --------------------------------------------------------------
      EXEC sp_log 1, @fn, '020: process';
      SET @class_start_str = FORMAT(@class_start, '0000');

      EXEC @row_cnt = sp_import_txt_file
         @table           = 'AttendanceGMeetStaging'
        ,@file            = @file
        ,@folder          = @folder
        ,@view            = 'ImportGMeetAttendanceStaging_vw'
        ,@field_terminator= @sep
        ,@display_table   = @display_tables
        ,@non_null_flds   = NULL
       ;

      EXEC sp_log 1, @fn, '030: imported ', @row_cnt,  ' rows';

      EXEC sp_log 1, @fn, '040: performing fixup';
      EXEC sp_fixup_AttendanceGMeetStaging @course_nm, @section_nm;

      IF @display_tables = 1
         SELECT * FROM AttendanceGMeetStaging;

      -- Populate AttendanceGMeet
      EXEC sp_log 1, @fn, '050: Populate AttendanceGMeet table';

      INSERT INTO AttendanceGMeet (student_id, student_nm, [date], class_start, course_nm, section_nm)
      SELECT a.student_id, a.candidate_nm, @date, @class_start_str, course_nm, section_nm
      FROM AttendanceGMeetStaging a
      LEFT JOIN Student s ON s.student_nm = a.line
      LEFT JOIN Enrollment_vw e ON a.student_id = e.student_id
      ;

      IF @display_tables = 1
         SELECT * FROM AttendanceGMeet;

      EXEC sp_log 1, @fn, '050: fixup complete';

      --------------------------------------------------------------
      -- Process complete
      --------------------------------------------------------------
      EXEC sp_log 1, @fn, '399: process complete';
   END TRY
   BEGIN CATCH
      EXEC sp_log 1, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, imported ', @row_cnt, ' rows';
END
/*
EXEC tSQLt.Run 'test.test_011_sp_ImportGMeetAttendance';

EXEC sp_ImportGMeetAttendance 'D:\Dorsu\Data\Attendance 250314.txt', '3/15/2025', 1500, 'ITC130', 'ITC_3C';

SELECT * FROM GMeetAttendance;
EXEC test.sp__crt_tst_rtns 'sp_ImportGMeetAttendance'
*/

GO
