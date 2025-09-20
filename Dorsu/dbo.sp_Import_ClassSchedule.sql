SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =========================================================================================
-- Author:         Terry Watts
-- Create date:    23-Feb-2025
-- Description:    Imports the Classschedule table from a tsv
-- Design:         EA Model.Use Case Model.Importing data.Generic Import of a table
--
-- Parameters:
--    file path:      full path to the import file
--    clr first:      if true clear the staging and main tables fist
--    sep:            field separator used in the import file tab or spc (1 character)
--    display tables: if true display the tables staging and main after import
--
-- Tests:          
-- Preconditions:  None
-- Postconditions: 
-- POST 01: ClassSchedule table populated
-- =========================================================================================
CREATE PROCEDURE [dbo].[sp_Import_ClassSchedule]
    @file            NVARCHAR(MAX)
   ,@folder          VARCHAR(500)   = NULL
   ,@clr_first       BIT            = 1
   ,@sep             CHAR           = 0x09
   ,@codepage        INT            = 65001
   ,@exp_row_cnt     INT            = NULL
   ,@display_tables  BIT            = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
    @fn              VARCHAR(35)    = 'sp_Import_ClassSchedule'
   ,@tab             NCHAR(1)       = NCHAR(9)
   ,@row_cnt         INT 
   ,@backslash       VARCHAR(2)     = CHAR(92)
   ;

   EXEC sp_log 1, @fn, '000: starting calling sp_import_txt_file
file:         :[', @file            ,']
folder:       :[', @folder          ,']
clr_first:    :[', @clr_first       ,']
sep:          :[', @sep             ,']
codepage      :[', @codepage        ,']
exp_row_cnt   :[', @exp_row_cnt     ,']
display_tables:[', @display_tables  ,']
';

   BEGIN TRY

      ----------------------------------------------------------------
      --Validate preconditions, parameters
      ----------------------------------------------------------------

      ----------------------------------------------------------------
      --Import text file
      ----------------------------------------------------------------

      EXEC sp_log 1, @fn, '010: calling sp_import_txt_file  @table: ClassScheduleStaging, @file: ',@file;

      EXEC @row_cnt = sp_import_txt_file 
          @table           = 'ClassScheduleStaging'
         ,@file            = @file
         ,@folder          = @folder
         ,@view            = 'ImportClassScheduleStaging_vw'
         ,@field_terminator= @sep
         ,@codepage        = @codepage
         ,@clr_first       = @clr_first
         ,@display_table   = @display_tables
         ,@exp_row_cnt     = @exp_row_cnt
      ;

      EXEC sp_log 1, @fn, '020: TRUNCATE TABLE ClassSchedule';
      TRUNCATE TABLE ClassSchedule;
      EXEC sp_log 1, @fn, '030: pop ClassSchedule';

      INSERT INTO ClassSchedule
           (
            course_id
           ,major_id
           ,section_id
           ,[day]
           ,dow
           ,st_time
           ,end_time
           ,[description]
           ,room_id
           )
           SELECT
            course_id
           ,major_id
           ,section_id
           ,[day]
           ,dbo.fnGetDowFromDayName(css.[day])
           ,SUBSTRING(times, 1,CHARINDEX('-',times)-1)
           ,SUBSTRING(times,   CHARINDEX('-',times)+1, 4)
           ,c.[description]
           ,room_id
      FROM ClassScheduleStaging css 
      left JOIN Course  c ON c.course_nm = css.course_nm
      left JOIN Major   m ON m.major_nm  = css.major_nm
      left JOIN Section s ON s.section_nm= css.section_nm
      left JOIN Room    R ON r.room_nm =   css.room_nm
      ;

      -- POST 01: ClassSchedule table populated
      EXEC sp_log 1, @fn, '040: inserted ',@row_cnt,' rows into ClassSchedule';
      EXEC sp_assert_tbl_pop 'ClassSchedule';

      IF @display_tables = 1
      BEGIN
         SELECT * FROM ClassScheduleStaging;
         SELECT * FROM ClassSchedule;
         SELECT * FROM ClassSchedule_vw;
      END
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving imported ',@row_cnt, ' rows';
   RETURN @row_cnt;
END
/*
EXEC test.test_060_sp_Import_ClassSchedule;

EXEC sp_drop_FKs;
EXEC sp_Import_ClassSchedule 'D:\Dorsu\Data\Class Schedule.Schedule 250317.txt', 1;
EXEC sp_create_FKs;
SELECT * FROM timetable_vw;

EXEC sp_Import_ClassSchedule 'D:\Dorsu\Data\Class Schedule.Schdeule 250221.txt', 1;
SELECT distinct Program from ClassScheduleStaging
SELECT * FROM Program;
SELECT * FROM Major;
SELECT * FROM ClassScheduleStaging
SELECT * FROM ClassSchedule
EXEC sp_AppLog_display 'sp__importSchema';
EXEC tSQLt.RunAll;
EXEC test.sp__crt_tst_rtns '[dbo].[sp_Import_ClassSchedule]';
*/

GO
