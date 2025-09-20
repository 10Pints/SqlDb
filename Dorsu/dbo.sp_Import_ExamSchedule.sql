SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =================================================================
-- Author:       Terry Watts
-- Create date:  25-Feb-2025
-- Description:  Imports the ExamSchedule table from a tsv
-- Design:       EA
-- Tests:        test.test_056_sp_Import_AttendanceStaging
-- Preconditions: All dependent tables have been cleared
-- Postconditions: pops the ExamSchedule table and returns row cnt 
-- =================================================================
CREATE PROCEDURE [dbo].[sp_Import_ExamSchedule]
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
       @fn        VARCHAR(35) = 'sp_Import_ExamSchedule'
      ,@tab       NCHAR(1)=NCHAR(9)
      ,@row_cnt   INT = 0
   ;

   EXEC sp_log 1, @fn, '000: starting calling sp_import_txt_file
file:          [',@file          ,']
folder:        [',@folder        ,']
clr_first:     [',@clr_first     ,']
sep:           [',@sep           ,']
codepage:      [',@codepage      ,']
display_tables:[',@display_tables,']
';

   BEGIN TRY
      EXEC @row_cnt = sp_import_txt_file 
          @table           = 'ExamScheduleStaging'
--         ,@view            = 'ImportExamSchedule_vw'
         ,@file            = @file
         ,@folder          = @folder
         ,@field_terminator= @sep
         ,@codepage        = @codepage
         ,@clr_first       = 1
         ,@display_table   = @display_tables
      ;

      EXEC sp_log 1, @fn, '010: imported ', @row_cnt,  ' rows';
      EXEC sp_log 1, @fn, '015: truncating table ExamSchedule';
      TRUNCATE TABLE ExamSchedule;
      EXEC sp_log 1, @fn, '010: copygn to main table ', @row_cnt,  ' rows';

      INSERT INTO ExamSchedule
      (
            [id]
           ,[days]
           ,[st]
           ,[end]
           ,[ex_st]
           ,[ex_end]
           ,[ex_date]
           ,[ex_day]
       )
       SELECT [id]
           ,[days]
           ,[st]
           ,[end]
           ,[ex_st]
           ,[ex_end]
           ,[ex_date]
           ,[ex_day]
      FROM 
         ExamScheduleStaging;

      EXEC sp_log 1, @fn, '499: completed processing, file: [',@file,']';
   END TRY
   BEGIN CATCH
      EXEC sp_log 1, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, imported ', @row_cnt, ' rows from file: [',@file,']';
   RETURN @row_cnt;
END
/*
EXEC test.test_057_sp_Import_ExamSchedule;

EXEC tSQLt.Run 'test.test_057_sp_Import_ExamSchedule';
EXEC tSQLt.RunAll;
// EXEC test.test_057_sp_Import_ExamSchedule'D:\Dorsu\Courses\Courses.Course.txt';
*/


GO
