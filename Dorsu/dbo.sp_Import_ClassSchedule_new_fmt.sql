SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ======================================================================
-- Description:    Imports the new format Classschedule table from a tsv
-- Design:         EA
-- Tests:          
-- Author:         Terry Watts
-- Create date:    23-Feb-2025
-- Preconditions:  None
-- Postconditions: ClassSchedule table populated
-- ======================================================================
CREATE PROCEDURE [dbo].[sp_Import_ClassSchedule_new_fmt]
    @file            NVARCHAR(MAX)
   ,@folder          VARCHAR(500)= NULL
   ,@clr_first       BIT         = 1
   ,@sep             CHAR        = 0x09
   ,@codepage        INT         = 65001
   ,@display_tables  BIT         = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn        VARCHAR(35) = 'sp_Import_ClassSchedule_new_fmt'
      ,@tab       NCHAR(1)=NCHAR(9)
      ,@row_cnt   INT

   EXEC sp_log 1, @fn, '000: starting calling sp_import_txt_file
file:          [',@file          ,']
folder:        [',@folder        ,']
clr_first:     [',@clr_first     ,']
sep:           [',@sep           ,']
codepage:      [',@codepage      ,']
display_tables:[',@display_tables,']
';

   BEGIN TRY
      EXEC sp_log 1, @fn, '020: TRUNCATE TABLE ClassScheduleNewStaging';
      TRUNCATE TABLE ClassScheduleNewStaging;
      EXEC sp_log 1, @fn, '010: calling sp_import_txt_file  @table: ClassScheduleStaging, @file: ',@file;
      EXEC @row_cnt = sp_import_txt_file 'ClassScheduleNewStaging', @file, @field_terminator=@tab;

      EXEC @row_cnt = sp_import_txt_file 
          @table           = 'ClassScheduleNewStaging'
         ,@file            = @file
         ,@folder          = @folder
         ,@field_terminator= @sep
         ,@codepage        = @codepage
         ,@clr_first       = @clr_first
         ,@display_table   = @display_tables
      ;

      EXEC sp_log 1, @fn, '030: pop ClassSchedule';

      /*
      INSERT INTO ClassSchedule
           (
            dow
           ,[day]
           ,st_time
           ,end_time
           ,course_id
           ,[description]
           ,lec_units
           ,lab_units
           ,tot_units
           ,major_id
           ,section_id
           ,room_id
           ,eus
           )
           SELECT
            dow
           ,[day]
           ,st_time
           ,end_time
           ,course_id
           ,[description]
           ,lec_units
           ,lab_units
           ,tot_units
           ,major_id
           ,section_id
           ,room_id
           ,eus
      FROM ClassScheduleStaging css 
      JOIN Course  c ON c.course_nm = css.course_nm
      JOIN Major   m ON m.major_nm  = css.major_nm
      JOIN Section s ON s.section_nm= css.section_nm
      JOIN Room    R ON r.room_nm =   css.room_nm
      ;
      */

      EXEC sp_log 1, @fn, '040: populated ClassScheduleNew';

      IF @display_tables = 1
      BEGIN
         SELECT * 
         FROM ClassScheduleNewStaging 
         CROSS Apply string_split('days', ',')  as [day]
         CROSS Apply string_split('times', ',') as st_time
         CROSS Apply string_split('rooms', ',') as room
         ;
      END
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving imported ',@row_cnt, ' rows';
END
/*
EXEC sp_Import_ClassSchedule_new_fmt 'D:\Dorsu\Data\Class Schedule.Schedule 250305.txt', 1;
SELECT distinct Program from ClassScheduleNewStaging;

SELECT * FROM Program;
SELECT * FROM Major;
SELECT * FROM ClassScheduleStaging
*/


GO
