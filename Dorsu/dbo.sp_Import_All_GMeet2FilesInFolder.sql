SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ============================================================================
-- Author:      Terry Watts
-- Create date: 01-APR-2025
-- Description: Imports all the GMeet attendance from the supplied folder
-- Design:      EA
-- Tests:       test_023_sp_ImportAllGMeet2FilesInFolder
--
-- Preconditions PRE001: folder must exist: chkd
--
-- Postconditions
-- POST 01: returns @fileCnt and successfule import of all files in folder or 
-- ============================================================================
CREATE PROCEDURE [dbo].[sp_Import_All_GMeet2FilesInFolder]
    @folder          VARCHAR(500)
   ,@file_mask       VARCHAR(20) = '*.csv'
   ,@display_tables  BIT = 0
AS
BEGIN
   SET NOCOUNT ON;

   DECLARE
    @fn              VARCHAR(35) = 'sp_ImportAllGMeet2FilesInFolder'
   ,@filename        VARCHAR(255)
   ,@table           VARCHAR(50) = 'AttendanceGMeet2Staging'
   ,@view            VARCHAR(50) = 'import_AttendanceGMeet2Staging_vw'
   ,@cnt             INT         = 0
   ,@fileCnt         INT         = 0
   ,@sql             VARCHAR(8000)
   ,@cmd             VARCHAR(1000)
   ,@backslash       CHAR        = CHAR(92)
   ,@tab             NCHAR       = NCHAR(9)
   ,@id              INT
   ,@date            VARCHAR(20)
   ,@time24          VARCHAR(20)
   ,@course_nm       VARCHAR(20)
   ,@section_nm      VARCHAR(20)
   ,@folder_exists   BIT
   ;

    EXEC sp_log 1, @fn ,'000: starting
folder         :[', @folder         , ']
file_mask      :[', @file_mask      , ']
display_tables :[', @display_tables , ']
';

   IF @view IS NULL
      SET @view = @table;

   BEGIN TRY
      EXEC sp_log 1, @fn ,'010: Validating inputs';
      -- Preconditions PRE001: folder exists chkd
      EXEC @folder_exists = sp_FolderExists @folder;--, @folder_exists OUT;
      EXEC sp_assert_equal 1, @folder_exists, 'PRE001: folder must exist'

      EXEC sp_log 1, @fn ,'010: TRUNCATING TABLE: AttendanceGMeet2Staging';
      TRUNCATE TABLE AttendanceGMeet2Staging;

      -------------------------------------------------
      -- Get the files from the folder
      -------------------------------------------------
      DELETE FROM Filenames;
      SET @cmd = CONCAT('dir ', @folder ,'\\', @file_mask, ' /b');

      EXEC sp_log 1, @fn ,'020: Get the files from the folder -> Filenames table, @cmd:
', @cmd ;

      INSERT INTO Filenames([file])
      EXEC Master..xp_cmdShell @cmd;

      DELETE FROM Filenames WHERE [file] IS NULL;

      IF @display_tables =1
         SELECT * FROM Filenames ORDER BY [file];

      EXEC sp_log 1, @fn ,'020: updating the Filenames paths ';
      UPDATE Filenames SET [path] = @folder WHERE [path] IS NULL;

      DECLARE c1 CURSOR FOR
         SELECT [file]
         FROM Filenames
         --WHERE [file] LIKE @file_mask
         ORDER BY [file]
      ;

      OPEN c1;
      FETCH NEXT FROM c1 INTO @filename;

      --------------------------------------------------
        -- Main import loop
     --------------------------------------------------
      EXEC sp_log 1, @fn ,'030: main import loop: importing all files in Filenames table';
      IF @@fetch_status = -1
         EXEC sp_log 3, @fn ,'035: no files were found in folder ',@folder,' that matched mask: ',@file_mask;

      WHILE @@fetch_status <> -1
      BEGIN
         SET @fileCnt = @fileCnt + 1;
         EXEC sp_log 1, @fn ,'040: import  [', @fileCnt,']:  importing:[', @filename,']';
       --SET @path = CONCAT(@folder, '\\', @filename);

         EXEC sp_Import_AttendanceGMeet2
             @file            = @filename
            ,@folder          = @folder
            ,@one_off         = 0
            ,@display_tables  = @display_tables
         ;

         FETCH NEXT FROM c1 INTO @filename;
      END

      CLOSE c1;
      DEALLOCATE c1;
      EXEC sp_log 1, @fn ,'050: completedfile import loop';

      --------------------------------------------------
      -- Merge to main table
      --------------------------------------------------
      EXEC sp_log 1, @fn ,'070: merge calling sp_merge_AttendanceGMeet2';
      EXEC sp_merge_AttendanceGMeet2;
      EXEC sp_log 1, @fn ,'080: merge completed';
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: Caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn ,'120:completed mn processing loop';
   EXEC sp_log 1, @fn ,'999: leaving, processing complete, imported ', @fileCnt,  ' files';
   RETURN @fileCnt;
END
/*
SELECT * FROM AttendanceGMeet2Staging ORDER BY participant_nm, course_nm, section_nm, [date], time_24;

EXEC test.test_023_sp_ImportAllGMeet2FilesInFolder;
SELECT count(*) FROM AttendanceGMeet2;
EXEC tSQLt.Run 'test.test_023_sp_ImportAllGMeet2FilesInFolder';
*/

GO
