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
CREATE PROCEDURE [dbo].[sp_create_FKs_Auth] @tables VARCHAR(MAX) = NULL
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
      -- 1: Foreign table UserRole: 2 FKs:  FK_UserRole_Role, FK_UserRole_User
      -------------------------------------------------------------------------------------------------------
      EXEC sp_create_FK 'FK_UserRole_Role' , 'UserRole', 'Role' , 'role_id' , @cnt=@cnt OUT;
      EXEC sp_create_FK 'FK_UserRole_User' , 'UserRole', '[User]', 'user_id', @cnt=@cnt OUT;;

      -------------------------------------------------------------------------------------------------------
      -- 1: Foreign table RoleFeature: 2 FKs:  FK_RoleFeature_Feature, FK_RoleFeature_Role
      -------------------------------------------------------------------------------------------------------
      EXEC sp_create_FK 'FK_RoleFeature_Feature', 'RoleFeature', 'Feature', 'feature_id', @cnt=@cnt OUT;;
      EXEC sp_create_FK 'FK_RoleFeature_Role'   , 'RoleFeature', 'Role'   , 'role_id'   , @cnt=@cnt OUT;;

      -------------------------
      -- Completed processing
      -------------------------
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving: created ', @cnt, ' Foreign key  constraints';
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
