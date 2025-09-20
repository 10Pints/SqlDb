SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- ==========================================================
-- Author:         Terry Watts
-- Create date:    03-APR-2025
-- Description:    drops all Auth schema foreign keys
-- Design:         EA
-- Tests:         test_004_sp_create_FKs
-- Preconditions:  none
-- Postconditions: Return value = count of dropped relations
-- Tests:       test_004_sp_create_FKs
-- ==========================================================
CREATE PROCEDURE [dbo].[sp_drop_FKs_Auth_old]
AS
BEGIN
 SET NOCOUNT ON;
   DECLARE
       @fn     VARCHAR(35) = 'sp_drop_FKs_Auth'
      ,@cnt    INT         = 0
   ;

   BEGIN TRY
      EXEC sp_log 1, @fn, '000: starting';

      ----------------------------------------
      --  Foreign table  UserRole
      ----------------------------------------
      EXEC sp_log 1, @fn, '005: dropping keys for Referenced table UserRole';

      IF dbo.fnFkExists('FK_UserRole_User') = 1
      BEGIN
         EXEC sp_log 1, @fn, '015: dropping constraint FK_UserRole_User';
         ALTER TABLE [dbo].[UserRole] DROP CONSTRAINT [FK_UserRole_User];
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '020: constraint UserRole.FK_UserRole_User does not exist';

      IF dbo.fnFkExists('FK_UserRole_Role') = 1
      BEGIN
         EXEC sp_log 1, @fn, '015: dropping constraint FK_UserRole_Role';
         ALTER TABLE [dbo].[UserRole] DROP CONSTRAINT [FK_UserRole_Role]
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '020: constraint UserRole.FK_UserRole_Role does not exist';

      ----------------------------------------
      -- Foreign table RoleFeature
      ----------------------------------------
      IF dbo.fnFkExists('FK_RoleFeature_Role') = 1
      BEGIN
         EXEC sp_log 1, @fn, '015: dropping constraint FK_RoleFeature_Role';
         ALTER TABLE [dbo].[RoleFeature] DROP CONSTRAINT FK_RoleFeature_Role;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '020: constraint RoleFeature.FK_RoleFeature_Role does not exist';

      IF dbo.fnFkExists('FK_RoleFeature_Feature') = 1
      BEGIN
         EXEC sp_log 1, @fn, '015: dropping constraint FK_RoleFeature_Feature';
         ALTER TABLE dbo.RoleFeature DROP CONSTRAINT FK_RoleFeature_Feature
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '020: constraint RoleFeature.FK_RoleFeature_Feature does not exist';

      ------------------------
      -- Completed processing
      ------------------------
      EXEC sp_log 1, @fn, '498: dropped all necessary constraints';
      EXEC sp_log 1, @fn, '499: completed processing';
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving: dropped ', @cnt, ' keys';
   RETURN @cnt;
END
/*
EXEC tSQLt.Run 'test.test_004_sp_create_FKs';
EXEC tSQL.RunAll;

EXEC sp_drop_FKs_Auth;
EXEC sp_create_FKs_Auth;
*/

GO
