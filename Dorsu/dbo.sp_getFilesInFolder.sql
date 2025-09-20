SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =======================================================================================
-- Author:      Terry Watts
-- Create date: 06-APR-2025
-- Description: Gets all the file names that match @mask from a directory
-- Design:      EA
-- Tests:       test_033_sp_getFilesInFolder
-- Postconditions: 
-- POST 01:if error throws exception ELSE returns the count of files in the folder
-- =======================================================================================
CREATE PROCEDURE [dbo].[sp_getFilesInFolder]
    @folder          VARCHAR(500)
   ,@mask            VARCHAR(60)
   ,@display_tables  BIT = 0
   ,@clr_first       BIT = 1
AS
BEGIN
   SET NOCOUNT ON;

   DECLARE 
    @fn              VARCHAR(35)= 'sp_getFilesInFolder'
   ,@cmd             VARCHAR(1000)
   ,@fileCnt         INT            = 0
   ;

    EXEC sp_log 1, @fn ,'000: starting
folder         :[', @folder        , ']
mask           :[', @mask          , ']
display_tables :[', @display_tables, ']
clr_first      :[', @clr_first     , ']
';

   If @clr_first = 1
   BEGIN
      EXEC sp_log 1, @fn ,'010: clearing Filenames table';
      DELETE FROM Filenames;
   END

   SET @cmd = CONCAT('dir "', @folder ,'\',@mask,'" /b');
   EXEC sp_log 1, @fn ,'010: @cmd:
', @cmd ;

   INSERT INTO Filenames([file])
   EXEC Master..xp_cmdShell @cmd;

   DELETE FROM Filenames 
   WHERE [file] IS NULL OR [file] = 'File Not Found';

   UPDATE Filenames SET [path] = @folder WHERE [path] IS NULL;

   If @display_tables = 1
      SELECT * FROM Filenames ORDER BY [file];

   SELECT @fileCnt = COUNT(*) FROM Filenames;
   EXEC sp_log 1, @fn ,'999: leaving, processing complete, found ', @fileCnt,  ' files';
   RETURN @fileCnt;
END
/*
EXEC tSQLt.RunAll;
EXEC test.test_033_sp_getFilesInFolder;
EXEC tSQLt.Run 'test.test_033_sp_getFilesInFolder';
EXEC test.sp__crt_tst_rtns 'dbo.sp_getFilesInFolder'
*/

GO
