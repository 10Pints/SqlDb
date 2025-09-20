SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ========================================================
-- Author:      Terry Watts
-- Create date: 1-MAR-2025
-- Description: Imports the User-role-auth Features schema
-- Design:      EA: Roles model
-- Tests:       test_034_sp_ImportAuthUserRoleFeature
-- Preconditions  None
--
-- Postconditions Features table imported
-- ========================================================
CREATE PROCEDURE [dbo].[sp_Import_All_AuthUserRoleFeature]
   @folder         NVARCHAR(MAX)
  ,@file_mask      NVARCHAR(50)
  ,@display_tables BIT = 1
AS
BEGIN
 SET NOCOUNT ON;
   DECLARE
       @fn        VARCHAR(35) = 'sp_Import_All_AuthUserRoleFeature'
      ,@file      VARCHAR(100)
      ,@path      VARCHAR(500)
      ,@file_path VARCHAR(600)
      ,@backslash CHAR(1)         = CHAR(92) --'\';

   BEGIN TRY
      EXEC sp_log 1, @fn, '000: starting, clearing tables';
      EXEC sp_drop_FKs_Auth;
      DELETE FROM RoleFeature;
      DELETE FROM UserRole;
      DELETE FROM [User];
      DELETE FROM [Role];
      DELETE FROM Feature;

      -- Get all the file name sin the folder
      EXEC sp_log 1, @fn, '010: calling sp_getFilesInFolder';
      EXEC sp_getFilesInFolder  @folder, @file_mask;
      EXEC sp_log 1, @fn, '020: ret frm sp_getFilesInFolder';

      --------------------------------------------------------------------
      -- ASSERTION: we have all the file names in the FileNames table;
      --------------------------------------------------------------------
      SELECT * FROM FileNames;

      DECLARE FileName_cursor CURSOR FAST_FORWARD FOR
      SELECT [file], [path]
      FROM FileNames;

      -- Open the cursor
      OPEN FileName_cursor;

         -- Fetch the first row
         FETCH NEXT FROM FileName_cursor INTO @file, @path;

      -- Start processing rows
      WHILE @@FETCH_STATUS = 0
      BEGIN
         -- Process the current row
         SET @file_path = CONCAT(@path, @backslash, @file);
         EXEC sp_log 1, @fn, '030: in file loop: file:      [', @file,']';
         EXEC sp_log 1, @fn, '030: in file loop: path:      [', @path, ']';
         EXEC sp_log 1, @fn, '030: in file loop: file_path: [',@file_path,']';

         IF      @file LIKE '%.UserRoles.%'     EXEC sp_Import_UserRole    @file_path, @display_tables = @display_tables;
         ELSE IF @file LIKE '%.Users.%'         EXEC sp_Import_User        @file_path, @display_tables = @display_tables;
         ELSE IF @file LIKE '%.Roles.%'         EXEC sp_Import_Role        @file_path, @display_tables = @display_tables;
         ELSE IF @file LIKE '%.RoleFeatures.%'  EXEC sp_Import_RoleFeature @file_path, @display_tables = @display_tables;
         ELSE IF @file LIKE '%.Features.%'      EXEC sp_Import_Feature     @file_path, @display_tables = @display_tables;
--            ELSE IF @file LIKE '%Sections%'      EXEC sp_Import_Section     @file_path, @display_tables;
--            ELSE IF @file LIKE '%Students%'      EXEC sp_Import_Students    @file_path, @display_tables;
         ELSE EXEC sp_log 1, @fn, '040:  not processing [', @file,  '] path: [', @path, ']';

         -- Fetch the next row
         EXEC sp_log 1, @fn, '050: getting next file from cursor';
         FETCH NEXT FROM FileName_cursor INTO @file, @path;
      END

      -- Clean up the cursor
      CLOSE FileName_cursor;
      DEALLOCATE FileName_cursor;

      EXEC sp_log 1, @fn, '399: process complete';
   END TRY
   BEGIN CATCH
      EXEC sp_log 1, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      -- Clean up the cursor
      CLOSE FileName_cursor;
      DEALLOCATE FileName_cursor;
      EXEC sp_create_FKs_Auth;
      THROW;
   END CATCH

   EXEC sp_create_FKs_Auth;
   EXEC sp_log 1, @fn, '999: leaving, imported the Auth-User-Role-Feature schema';
END
/*
EXEC test.test_034_sp_Import_All_AuthUserRoleFeature;

EXEC sp_Import_All_AuthUserRoleFeature   
   @folder         ='D:\Dorsu\Tests\test_037'
  ,@file_mask      = '*.txt'
  ,@display_tables = 1
  ;

EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_034_sp_Import_All_AuthUserRoleFeature';
*/

GO
