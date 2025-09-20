SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =====================================================
-- Description: re creates all Auth schema foreign keys
--              after total import
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 03-APR-2025
-- =====================================================
CREATE PROCEDURE [dbo].[sp_create_FKs_Auth_old] @tables VARCHAR(MAX) = NULL
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE 
       @fn     VARCHAR(35) = 'sp_create_FKs_Auth'
      ,@cnt    INT         = 0
   ;

   BEGIN TRY
      EXEC sp_log 1, @fn, '000: starting, @tables: ', @tables, '';


      -------------------------------------------------------------------------------------------------------
      -- 1: Foreign table UserRole
      -------------------------------------------------------------------------------------------------------
      IF dbo.fnFkExists('FK_UserRole_User') = 0
      BEGIN
         EXEC sp_log 1, @fn, '005: recreating constraint UserRole.FK_UserRole_User';
         ALTER TABLE UserRole WITH CHECK ADD CONSTRAINT FK_UserRole_User FOREIGN KEY([user_id]) REFERENCES dbo.[User]([user_id]);
         ALTER TABLE UserRole CHECK CONSTRAINT FK_UserRole_User;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '010: constraint UserRole.FK_UserRole_User already exists';

      IF dbo.fnFkExists('FK_UserRole_Role') = 0
      BEGIN
         EXEC sp_log 1, @fn, '015: recreating constraint UserRole.FK_UserRole_Role';
         ALTER TABLE UserRole WITH CHECK ADD CONSTRAINT FK_UserRole_Role FOREIGN KEY(role_id) REFERENCES dbo.[Role](role_id);
         ALTER TABLE UserRole CHECK CONSTRAINT FK_UserRole_Role;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '020: constraint UserRole.FK_UserRole_Use already exists';

      -------------------------------------------------------------------------------------------------------
      -- 1: Foreign table RoleFeature
      --------------------------------------------------------------
      IF dbo.fnFkExists('FK_RoleFeature_Role') = 0
      BEGIN
         EXEC sp_log 1, @fn, '025: recreating constraint FK_RoleFeature_Role';
         ALTER TABLE dbo.RoleFeature WITH CHECK ADD CONSTRAINT FK_RoleFeature_Role FOREIGN KEY(role_id) REFERENCES dbo.[Role](Role_id)
         ALTER TABLE dbo.RoleFeature CHECK CONSTRAINT FK_RoleFeature_Role
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '030: constraint RoleFeature.FK_RoleFeature_Role already exists';

      IF dbo.fnFkExists('FK_RoleFeature_Feature') = 0
      BEGIN
         EXEC sp_log 1, @fn, '035: recreating constraint FK_RoleFeature_Feature';
         ALTER TABLE RoleFeature WITH CHECK ADD CONSTRAINT FK_RoleFeature_Feature FOREIGN KEY(feature_id) REFERENCES dbo.Feature(feature_id);
         ALTER TABLE RoleFeature CHECK CONSTRAINT FK_RoleFeature_Feature;
         SET @cnt = @cnt + 1;
      END
      ELSE
         EXEC sp_log 1, @fn, '040: constraint RoleFeature.FK_RoleFeature_Feature already exists';

      ------------------------
      -- Completed processing
      ------------------------
      EXEC sp_log 1, @fn, '498: created all necessary constraints';
      EXEC sp_log 1, @fn, '499: completed processing';


   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving: created ', @cnt, ' keys';
   RETURN @cnt;
END
/*
EXEC sp_drop_FKs_Auth;
EXEC sp_create_FKs_Auth;
SELECT * FROM [User]
SELECT * FROM [Role]
SELECT * FROM [UserRole]
SELECT * FROM Feature
SELECT * FROM [RoleFeature]
*/


GO
