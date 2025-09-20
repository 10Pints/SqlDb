SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =========================================================
-- Description: Imports theRoom table from a tsv
--
-- Notes: Will truncate table ClassSchedule
-- Design:      EA
-- Tests:       
-- Author:      Terry Watts
-- Create date: 25-Feb-2025
-- Preconditions: related FKs have been dropped
-- =========================================================
CREATE PROCEDURE [dbo].[sp_Import_Room]
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
       @fn        VARCHAR(35) = 'sp_Import_Room'
      ,@tab       NCHAR(1)    = NCHAR(9)
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
          @table           = 'Room'
         ,@file            = @file
         ,@folder          = @folder
         ,@field_terminator= @sep
         ,@codepage        = @codepage
         ,@clr_first       = @clr_first
         ,@display_table   = @display_tables
      ;

      EXEC sp_log 1, @fn, '010: imported ', @row_cnt,  ' rows';
   END TRY
   BEGIN CATCH
      EXEC sp_log 1, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, imported ', @row_cnt, ' rows';
END
/*
EXEC sp_Import_Room 'D:\Dorsu\Data\Rooms.rooms.txt';
EXEC tSQLt.Run 'test.test_003_sp_Import_Room';
SELECT * FROM Room;
*/


GO
