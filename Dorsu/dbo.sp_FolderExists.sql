SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ===============================================================
-- Author:      Terry Watts
-- Create date: 25-APR-2025
-- Description: returns @result = true if the file exists, false otherwise
-- also proc returns @result
-- Tests:       test.test_047_sp_FolderExists
-- ===============================================================
CREATE PROC [dbo].[sp_FolderExists] @path varchar(512), @result BIT = NULL OUT
AS
BEGIN
   DELETE FROM dbo.FileExists;
   INSERT INTO dbo.FileExists EXEC master.dbo.xp_fileexist @path;
   SELECT @result = folder_exists FROM FileExists;
   RETURN @result;
END
/*
EXEC test.sp__crt_tst_rtns 'sp_FolderExists'
*/

GO
