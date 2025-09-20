SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Description: Imports all the GMeet attendance from the supplied folder
-- Design:      EA
-- Tests:       
-- Author:      Terry Watts
-- Create date: 01-APR-2025
-- =============================================
CREATE PROCEDURE [dbo].[sp_Import_All_FilesInFolder]
    @folder          VARCHAR(500)
   ,@mask            VARCHAR(60)    = '*.txt'
   ,@table           VARCHAR(50)
   ,@view            VARCHAR(50)    = NULL
   ,@clr_first       BIT = 1
   ,@display_tables  BIT = 0
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE @fn       VARCHAR(35)    = 'sp_ImportAllFilesInFolder'
   ,@filename        VARCHAR(255)
   ,@fileCnt         INT            = 0
   ,@sql             VARCHAR(8000)
   ,@cmd             VARCHAR(1000)
   ,@path            VARCHAR(500)
   ,@backslash       CHAR           = CHAR(92)
   ,@tab             NCHAR          = NCHAR(9)
   ;

    EXEC sp_log 1, @fn ,'000: starting
folder         :[', @folder         , ']
mask           :[', @mask           , ']
table          :[', @table          , ']
view           :[', @view           , ']
clr_first      :[', @clr_first      , ']
display_tables :[', @display_tables , ']
';

/*
   IF @clr_first = 1
   BEGIN
    --SET  @cmd = CONCAT('DELETE from [', @table, ']');
    --SET  @cmd = CONCAT('TRUNCATE  TABLE [', @table, ']');
    --EXEC @cmd;
    ;
   END
*/
   IF @view IS NULL
      SET @view = @table;
   EXEC sp_getFilesInFolder
       @folder          = @folder
      ,@mask            = @mask
      ,@display_tables  = @display_tables
   ;

   BEGIN TRY
      --cursor loop
      DECLARE c1 CURSOR FOR
         SELECT /*[path], */[file]
         FROM Filenames
         WHERE [file] like '%.txt'
         ORDER BY [file]
      ;

      OPEN c1;
      FETCH NEXT FROM c1 INTO @filename;

      EXEC sp_log 1, @fn ,'010:B4 mn loop';
      WHILE @@fetch_status <> -1
      BEGIN
         SET @fileCnt = @fileCnt + 1;
         PRINT '';
         EXEC sp_log 1, @fn ,'020:in mn loop [', @fileCnt,']: @filename:[', @filename,']';
         SET @path = CONCAT(@folder, '\\', @filename);

         EXEC sp_import_txt_file 
           @table
          ,@path
          ,@clr_first      = 0
          ,@view           = @view
          ,@display_table  = @display_tables
         ;

         EXEC sp_log 1, @fn ,'030: ret frm sp_import_txt_file';
         FETCH NEXT FROM c1 INTO @filename;
         EXEC sp_log 1, @fn ,'040: next file: ', @filename;
      END -- while files loop

      EXEC sp_log 1, @fn ,'050:done mn loop';
      CLOSE c1;
      DEALLOCATE c1;
   END TRY
   BEGIN CATCH
      EXEC sp_log 1, @fn ,'0500 caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   --delete from ALLFILENAMES where WHICHFILE is NULL
   --select * from ALLFILENAMES
   EXEC sp_log 1, @fn ,'999: leaving, processing complete, imported ', @fileCnt,  ' files';
   RETURN @fileCnt;
END
/*
EXEC test.test_020_sp_ImportAllFilesInFolder;
EXEC tSQLt.Run 'test.test_020_sp_ImportAllFilesInFolder';
EXEC test.sp__crt_tst_rtns '[dbo].[sp_ImportAllFilesInFolder]';
*/

GO
