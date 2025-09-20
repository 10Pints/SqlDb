SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =========================================================
-- Description: Imports the Role table from a tsv
-- Design:      EA
-- Tests:       test_027_sp_Import_Feature
-- Author:      Terry Watts
-- Create date: 31-MAR-2025
-- =========================================================
CREATE PROCEDURE [dbo].[sp_Import_Feature]
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
       @fn        VARCHAR(35) = 'sp_Import_Feature'
      ,@row_cnt   INT         = 0
   ;

   EXEC sp_log 1, @fn, '000: starting calling sp_import_txt_file, params:';
   EXEC sp_log 1, @fn, '000: file:          [',@file          ,']';
   EXEC sp_log 1, @fn, '000: folder:        [',@folder        ,']';
   EXEC sp_log 1, @fn, '000: clr_first:     [',@clr_first     ,']';
   EXEC sp_log 1, @fn, '000: sep:           [',@sep           ,']';
   EXEC sp_log 1, @fn, '000: codepage:      [',@codepage      ,']';
   EXEC sp_log 1, @fn, '000: display_tables:[',@display_tables,']';

   BEGIN TRY
      ----------------------------------------------------------------
      -- Validate preconditions, parameters
      ----------------------------------------------------------------

      ----------------------------------------------------------------
      -- Setup
      ----------------------------------------------------------------

      ----------------------------------------------------------------
      -- Import text file
      ----------------------------------------------------------------
      EXEC @row_cnt = sp_import_txt_file 
          @table           = 'Feature'
         ,@file            = @file
         ,@folder          = @folder
         ,@field_terminator= @sep
         ,@codepage        = @codepage
         ,@clr_first       = @clr_first
         ,@display_table   = @display_tables
      ;
      EXEC sp_log 1, @fn, '010: process complete';
   END TRY
   BEGIN CATCH
      EXEC sp_log 1, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, imported ', @row_cnt, ' rows into the Feature table';
END
/*
EXEC sp_Import_Feature 'D:\Dorsu\data\UsersRolesFeatures.Features.txt';
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_027_sp_Import_Feature';
*/


GO
