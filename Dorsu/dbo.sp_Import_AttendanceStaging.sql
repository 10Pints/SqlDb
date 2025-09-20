SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===========================================================================
-- Author:         Terry Watts
-- Create date:    17-Mar-2025
-- Description:    Imports 2 Attendance staging tables from a tsv
--                 AttendanceStagingHdr and AttendanceStaging
--
-- sp_Import_AttendanceStaging Responsibilities:
-- Import AttendanceStagingCourseHdr
-- Import AttendanceStagingHdr
-- Import AttendanceStaging
-- Clean pop AttendanceStagingColMap
-- Update AttendanceStaging with course and section data
-- Clean pop AttendanceStagingDetail with the time and sched id
--
-- Design:         EA
-- Tests:          test_012_sp_Import_AttendanceStaging
--                 test_056_sp_Import_AttendanceStaging
--
-- Preconditions:  none
--
-- Postconditions:
--    POST 01: the following tables are popd: AttendanceStagingHdr, AttendanceStaging, AttendanceStagingColMap, AttendanceStagingDetail
--    POST 02: returns the count of rows imported, error thrown otherwise,
--    POST 03: AttendanceStagingDetail.classSchedule_id is not NULL
-- ===========================================================================
CREATE PROCEDURE [dbo].[sp_Import_AttendanceStaging]
    @file            VARCHAR(500)
   ,@folder          VARCHAR(500)= NULL
   ,@clr_first       BIT         = 1
   ,@sep             CHAR        = 0x09
   ,@codepage        INT         = 65001
   ,@display_tables  BIT         = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn              VARCHAR(40) = 'sp_Import_AttendanceStaging'
      ,@tab             CHAR(1)=CHAR(9)
      ,@row_cnt         INT
      ,@course_nm       VARCHAR(20) = NULL
      ,@section_nm      VARCHAR(20) = NULL
      ,@txt1            VARCHAR(MAX) = NULL
      ,@txt2            VARCHAR(MAX) = NULL
      ,@len1            INT
      ,@len2            INT

   EXEC sp_log 1, @fn, '000: starting
file:          [', @file          ,']
folder:        [', @folder        ,']
clr_first:     [', @clr_first     ,']
sep:           [', @sep           ,']
codepage:      [', @codepage      ,']
display_tables:[', @display_tables,']
';

   BEGIN TRY
      ----------------------------------------------------------------
      -- Validate preconditions, parameters
      ----------------------------------------------------------------
      EXEC sp_log 1, @fn, '005: Validating preconditions: none';

      ----------------------------------------------------------------
      -- Setup
      ----------------------------------------------------------------

      ----------------------------------------------------------------
      -- Import AttendanceStagingCourseHdr table
      ----------------------------------------------------------------
      EXEC sp_log 1, @fn, '010: importing the AttendanceStagingCourseHdr';

      EXEC @row_cnt = sp_import_txt_file 
          @table           = 'AttendanceStagingCourseHdr'
         ,@view            = 'ImportAttendanceStagingCourseHdr_vw'
         ,@file            = @file
         ,@folder          = @folder
         ,@first_row       = 1
         ,@last_row        = 1
         ,@field_terminator= @sep
         ,@display_table   = @display_tables
         ,@non_null_flds   = 'course_nm,section_nm'
      ;

      -- 250621: removing trailing wsp
      UPDATE AttendanceStagingCourseHdr SET stage = dbo.fnTrim(stage);

      -- Get the course and section data from the AttendanceStagingCourseHdr table
      --45	ITC 130	IT 3C	46	Tue	Tue	Thu	Thu	Tue	Tue	Thu	Thu	Tue	Tue	Thu	Thu	Tue	Tue	Thu	Thu	Tue	Tue	Thu	Thu
      --IT 3C 46 Tue Tue Thu Thu Tue Tue Thu Thu Tue Tue Thu Thu Tue Tue Thu Thu Tue Tue Thu Thu

      ---------------------------------------------------
      -- Check no trailing empty columns
      ---------------------------------------------------
      SELECT @txt1 = hdr FROM AttendanceStagingHdr;
      SET @txt2 = TRIM(@txt1);
      SET @len1 = dbo.fnLen(@txt1);
      SET @len2 = dbo.fnLen(@txt2);
      EXEC sp_assert_equal @len1, @len2, 'AttendanceStagingHdr.hdr contains trailing spcs';

      SELECT
          @course_nm = dbo.fnTrim(course_nm)
         ,@section_nm= dbo.fnTrim(section_nm)
      FROM AttendanceStagingCourseHdr;

      ----------------------------------------------------------------
      -- Import AttendanceStagingHdr table
      ----------------------------------------------------------------
      EXEC sp_log 1, @fn, '020: importing the AttendanceStagingHdr,
@course_nm:  ', @course_nm,'
@section_nm: ', @section_nm
;

      ----------------------------------------------------------------
      -- Assertion: @course_nm, @section_nm specified
      ----------------------------------------------------------------
      EXEC sp_assert_not_null_or_empty @course_nm;
      EXEC sp_assert_not_null_or_empty @section_nm;

      EXEC @row_cnt = sp_import_txt_file
          @table           = 'AttendanceStagingHdr'
         ,@file            = @file
         ,@folder          = @folder
         ,@first_row       = 2
         ,@last_row        = 3
         ,@field_terminator= @sep
         ,@codepage        = @codepage
         ,@display_table   = @display_tables
      ;

     -- SELECT * FROM AttendanceStagingHdr;

      EXEC sp_log 1, @fn, '030: TRUNCATE TABLEs AttendanceStagingColMap, AttendanceStaging';
      TRUNCATE TABLE AttendanceStagingColMap;
      TRUNCATE TABLE AttendanceStaging;

      ----------------------------------------------------------------
      -- Cleanpop the AttendanceStagingColMap dt and time24 columns
      ----------------------------------------------------------------
      EXEC sp_log 1, @fn, '040: Cleanpop the AttendanceStagingColMap dt and time24 columns';

      INSERT INTO AttendanceStagingColMap(ordinal, dt)
      SELECT ordinal, dbo.fnCovertStringToDate([value])
      FROM AttendanceStagingHdr h CROSS APPLY string_split(h.hdr, NCHAR(9), 1)
      WHERE VALUE <> '' AND h.id = 1;
      ;

      EXEC sp_chk_flds_not_null 'AttendanceStagingColMap', 'ordinal,dt';

      EXEC sp_log 1, @fn, '043: UPDATE AttendanceStagingColMap SET time24';
      UPDATE AttendanceStagingColMap
      SET time24 =  VALUE
      FROM AttendanceStagingHdr h CROSS APPLY string_split(h.hdr, NCHAR(9), 1) x
      JOIN AttendanceStagingColMap m on m.ordinal = x.ordinal
      WHERE x.VALUE <> '' AND h.id = 2;
      ;

      EXEC sp_chk_flds_not_null 'AttendanceStagingColMap', 'time24';


      ----------------------------------------------------------------
      -- Pop the AttendanceStagingColMap schedule_id column
      ----------------------------------------------------------------
      EXEC sp_log 1, @fn, '045: UPDATE AttendanceStagingColMap SET schedule_id';
      UPDATE AttendanceStagingColMap
      SET schedule_id = dbo.fnGetScheduleIdForDateTime(dt, time24);

      EXEC sp_log 1, @fn, '046:';
      SELECT * FROM AttendanceStagingColMap;

      EXEC sp_log 1, @fn, '047: Checking AttendanceStagingColMap for bad schedule_ids';
      IF EXISTS (SELECT 1 FROM AttendanceStagingColMap WHERE schedule_id IS NULL OR schedule_id = -1)
         EXEC sp_raise_exception 51234, 'AttendanceStagingColMap: not all schedule_ids were found', @fn=@fn;

      EXEC sp_log 1, @fn, '048:';
      IF @display_tables = 1 SELECT * FROM AttendanceStagingColMap;

      ----------------------------------------------------------------
      -- Import the AttendanceStaging table
      ----------------------------------------------------------------
      EXEC sp_log 1, @fn, '050: importing the AttendanceStaging table rows, @file: ',@file;
      EXEC @row_cnt = sp_import_txt_file 
          @table           = 'AttendanceStaging'
         ,@view            = 'ImportAttendanceStaging_vw'
         ,@file            = @file
         ,@folder          = @folder
         ,@first_row       = 6
         ,@codepage        = @codepage
         ,@clr_first       = @clr_first
         ,@field_terminator= @sep
         ,@display_table   = @display_tables
      ;

      ----------------------------------------------------------------
      -- Update the course and section id and nm fields
      ----------------------------------------------------------------

      EXEC sp_log 1, @fn, '060: UPDATE AttendanceStaging
course_nm: [',@course_nm,']
section_nm:[',@section_nm,']'
;

      -- do first
      UPDATE AttendanceStaging
      SET
          course_nm  = @course_nm
         ,section_nm = @section_nm
      ;

      -- do second
      UPDATE AttendanceStaging
      SET
          course_id  = c.course_id
         ,section_id = s.section_id
      FROM AttendanceStaging attStg
      LEFT JOIN Course  c ON attStg.course_nm   = @course_nm
      LEFT JOIN section s ON attStg.section_nm = @section_nm

      IF @display_tables = 1 SELECT * FROM AttendanceStaging;

      EXEC sp_chk_flds_not_null 'AttendanceStaging', 'course_nm,section_nm,course_id,section_id';

      -- AttendanceStagingDetail holds the student id, ordinal, present status
      -- Clean populate AttendanceStagingDetail

      --------------------------------------------------------------------------------
      -- Clean pop the AttendanceStagingDetail table from the AttendanceStaging table
      --------------------------------------------------------------------------------
      TRUNCATE TABLE AttendanceStagingDetail;
      INSERT INTO AttendanceStagingDetail(student_id, ordinal, present)
      SELECT student_id,ordinal, iif(value ='', NULL, value) as present
      FROM AttendanceStaging CROSS APPLY string_split(stage, CHAR(9), 1)
      WHERE (value IS NOT NULL AND value <> '')
      ;

      -------------------------------------------------------------
      -- Update AttendanceStagingDetail with the time and sched id
      -------------------------------------------------------------
      UPDATE AttendanceStagingDetail
      SET
          [date]      = cm.dt
         ,schedule_id = cm.schedule_id
      FROM
      AttendanceStagingDetail asd JOIN AttendanceStagingColMap cm ON asd.ordinal = cm.ordinal
      ;

      IF @display_tables = 1 SELECT * FROM AttendanceStagingDetail;

      ------------------------
      -- Chk postconditions
      ------------------------
      EXEC sp_log 1, @fn, '100: Checking postconditions';

      -- POST 03: AttendanceStagingDetail.classSchedule_id is not NULL
      EXEC sp_chk_flds_not_null 'AttendanceStagingDetail','schedule_id', @msg='proc: sp_Import_AttendanceStaging';

      ------------------------
      -- Completed processing
      ------------------------

      EXEC sp_log 1, @fn, '300: Completed processing';
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   -- POST 02: returns the count of rows imported, error thrown otherwise,
   EXEC sp_log 1, @fn, '999: leaving imported ',@row_cnt, ' rows';
   RETURN @row_cnt;
END
/*
EXEC test.test_012_sp_Import_AttendanceStaging;
EXEC test.test_056_sp_Import_AttendanceStaging;
SELECT * FROM Course,section
SELECT * FROM Course
SELECT * FROM AttendanceStaging;
EXEC sp_AppLog_display 'sp_ImportAttendanceStaging,hlpr_056_sp_Import_AttendanceStaging,sp_import_txt_file'
EXEC sp_AppLog_display 'sp_ImportAttendanceStaging'
SELECT * From AttendanceStagingColMap;
SELECT * From AttendanceStagingCourseHdr;
SELECT * From AttendanceStagingHdr;
SELECT * From AttendanceStaging
SELECT * FROM AttendanceStagingDetail;
SELECT * FROM AttendanceStagingDetail WHERE student_id = '2023-1908' -- IS NULL;

*/

GO
