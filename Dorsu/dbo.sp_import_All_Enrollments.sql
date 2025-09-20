SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ============================================================
-- Author:         Terry watts
-- Create date:    23-Feb-2025
-- Description:    Imports all Student enrollments
-- Design:      
-- Tests:       
-- Preconditions: 
--    PRE 01: all necessary FKs dropped
--    PRE 02: course, section  data imported
-- Postconditions:
--    POT 01: all student course, section  data imported
--```and returns the number of rows imnported
--          error otherwise
-- ============================================================
CREATE PROCEDURE [dbo].[sp_import_All_Enrollments]
 @folder          VARCHAR(500)= NULL
,@mask            VARCHAR(50) = NULL
,@sep             VARCHAR(50) = NULL
,@display_tables  BIT         = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
       @fn        VARCHAR(35) = 'sp_import_All_Enrollments'
      ,@file      VARCHAR(100)
      ,@path      VARCHAR(500)
      ,@backslash CHAR(1)     = CHAR(92) --'\';
      ,@row_cnt   INT         = 0
      ,@delta     INT

   EXEC sp_log 1, @fn, '000: starting
@folder:        [',@folder        ,']
@mask:          [',@mask          ,']
@set:           [',@sep           ,']
@display_tables:[',@display_tables,']
';

   BEGIN TRY
      --------------------------------------------------------
      -- VALIDATION
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '010: validating';

      --------------------------------------------------------
      -- Defaults
      --------------------------------------------------------
      IF @folder IS NULL
      BEGIN
         SET @folder = 'D:\Dorsu\Data';
         EXEC sp_log 1, @fn, '020: setting the folder to the default: ',@folder;
      END

      -- Create the import file mask
      IF @mask IS NULL SET @mask = '*.txt';
      IF @sep IS NULL  SET @sep  = CHAR(9); -- tab;

      --------------------------------------------------------
      -- Process
      --------------------------------------------------------
       EXEC sp_log 1, @fn, '030: Processing using the following params:
@folder:        [',@folder        ,']
@mask:          [',@mask          ,']
@set:           [',@sep           ,']
@display_tables:[',@display_tables,']
';

      -- Get all the file nams in the given folder that match the file mask
       EXEC sp_getFilesInFolder @folder, @mask, @display_tables;

   -----------------------------------------------
   -- ASSERTION: the filenames table is populated
   ----------------------------------------------

      DECLARE FileName_cursor CURSOR FAST_FORWARD FOR
      SELECT [file], [path]
      FROM FileNames;

      -- Open the cursor
      OPEN FileName_cursor;
      EXEC sp_log 1, @fn, '040: B$ import file loop';
      -- Fetch the first row
      FETCH NEXT FROM FileName_cursor INTO @file, @path;

      -- Start processing rows
      WHILE @@FETCH_STATUS = 0
      BEGIN
         -- Process the current row
         EXEC sp_log 1, @fn, '050: in file loop: calling sp_Import_Enrollment, file: ', @file,  ' @folder: [', @folder, ']  ';
         EXEC @delta = sp_Import_Enrollment @file, @folder, @clr_first=0, @sep=@sep;
         EXEC sp_log 1, @fn, '060: imported ',@row_cnt, ' rows';
         SET @row_cnt = @row_cnt + @delta;
         -- Fetch the next row
         FETCH NEXT FROM FileName_cursor INTO @file, @path;
      END

      -- Clean up the cursor
      CLOSE FileName_cursor;
      DEALLOCATE FileName_cursor;

            --------------------------------------------------------
      -- ASSERTION: completed processing
      --------------------------------------------------------
      EXEC sp_log 1, @fn, '399: completed processing';
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      -- Clean up the cursor
      CLOSE FileName_cursor;
      DEALLOCATE FileName_cursor;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving imported ',@row_cnt, ' rows';
   RETURN @row_cnt;
END
/*
EXEC test.test_054_sp_import_All_Enrollments;

EXEC tSQLt.Run 'test.test_054_sp_import_All_Enrollments';

EXEC tSQLt.RunAll;
*/

GO
