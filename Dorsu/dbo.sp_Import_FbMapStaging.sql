SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =========================================================
-- Description:   Imports the FbMap table from a tsv
-- Design:        
-- Tests:         
-- Author:        Terry Watts
-- Create date:   26-Mar-2025
-- Preconditions: none
-- =========================================================
CREATE PROCEDURE [dbo].[sp_Import_FbMapStaging]
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
       @fn        VARCHAR(35) = 'sp_Import_FbMap'
      ,@tab       NCHAR(1)=NCHAR(9)
      ,@row_cnt   INT = 0


   EXEC sp_log 1, @fn, '000: starting calling sp_import_txt_file
file:          [',@file          ,']
folder:        [',@folder        ,']
clr_first:     [',@clr_first     ,']
sep:           [',@sep           ,']
codepage:      [',@codepage      ,']
display_tables:[',@display_tables,']
';

   BEGIN TRY
      EXEC sp_log 1, @fn, '000: starting, file: ',@file,' truncating FbMap table';
      TRUNCATE TABLE FbMapStaging;

      EXEC @row_cnt = sp_import_txt_file
          @table           = 'FbMapStaging'
         ,@file            = @file
         ,@folder          = @folder
         ,@field_terminator= @sep
         ,@codepage        = @codepage
         ,@clr_first       = @clr_first
         ,@display_table   = @display_tables
      ;


      EXEC sp_log 1, @fn, '010: imported ', @row_cnt,  ' rows';
      EXEC sp_log 1, @fn, '399: finished importing file: ',@file,'';
   END TRY
   BEGIN CATCH
      EXEC sp_log 1, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      --EXEC sp_create_FKs 'Section';
      THROW;
   END CATCH


   EXEC sp_log 1, @fn, '999: leaving, imported ', @row_cnt, ' rows from ',@file;
   RETURN @row_cnt;
END
/*
EXEC sp_Import_FbMapStaging 'D:\Dorsu\Data\Teams.FB Name map.txt', 1;
EXEC sp_importAllStudentCourses;
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<proc_nm>';
EXEC test.sp__crt_tst_rtns '[dbo].[sp_Import_FbMap]';
*/


GO
