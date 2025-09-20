SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =================================================================
-- Author:         Terry Watts
-- Create date:    09-Jun-2025
-- Description:    Imports the FileActivityStaging table from a tsv
-- Design:         EA
-- Tests:          test_066_sp_Import_FileActivityStaging
-- Preconditions: 
-- Postconditions:
-- =================================================================
CREATE PROCEDURE [dbo].[sp_Import_FileActivitystaging]
    @file            NVARCHAR(MAX)
   ,@folder          VARCHAR(500)= NULL
   ,@clr_first       BIT         = 1
   ,@sep             CHAR        = ','
   ,@codepage        INT         = 65001
   ,@display_tables  BIT         = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE 
       @fn        VARCHAR(35) = 'sp_Import_FileActivityStaging'
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
          @table           = 'FileActivityLogStaging'
         ,@file            = @file
         ,@folder          = @folder
         ,@field_terminator= @sep
         ,@codepage        = @codepage
         ,@clr_first       = @clr_first
         ,@display_table   = @display_tables
      ;

      EXEC sp_log 1, @fn, '010: imported ', @row_cnt,  ' rows';
      EXEC sp_log 1, @fn, '499: completed processing, file: [',@file,']';
   END TRY
   BEGIN CATCH
      EXEC sp_log 1, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, imported ', @row_cnt, ' rows from file: [',@file,']';
END
/*
EXEC test.test_066_sp_Import_FileActivityStaging;

EXEC sp_Import_FileActivitystaging 'D:\Dorsu\Data\FileActivityLog.tsv';

EXEC tSQLt.Run 'test.test_066_sp_Import_FileActivityStaging';
EXEC tSQLt.RunAll;
*/


GO
