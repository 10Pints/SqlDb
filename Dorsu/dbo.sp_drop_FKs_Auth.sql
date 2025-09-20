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
CREATE PROCEDURE [dbo].[sp_drop_FKs_Auth]
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
      EXEC sp_log 1, @fn, '010: dropping keys for table UserRole';
      EXEC sp_drop_FK 'FK_UserRole_User';
      EXEC sp_drop_FK 'FK_UserRole_Role';

      ----------------------------------------
      -- Foreign table RoleFeature
      ----------------------------------------
      EXEC sp_log 1, @fn, '020: dropping keys for table RoleFeature';
      EXEC sp_drop_FK 'FK_RoleFeature_Role';
      EXEC sp_drop_FK 'FK_RoleFeature_Feature';

      ------------------------
      -- Completed processing
      ------------------------
      EXEC sp_log 1, @fn, '498: dropped all Auth constraints';
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
