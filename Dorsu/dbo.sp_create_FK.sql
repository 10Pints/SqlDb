SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ================================================================
-- Description: creates a relationship
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 07-MAR-2025
--
-- PRECONDITIONS:
-- PRE 01 @fk_nm        NOT NULL or EMPTY
-- PRE 02 @f_table_nm   NOT NULL or EMPTY
-- PRE 03 @col_nm NOT   NULL or EMPTY
-- PRE 04 @p_table_nm   NOT NULL or EMPTY
-- PRE 05 @p_schema_nm  NOT NULL or EMPTY
--
-- POSTCONDITIONS:
-- POST 01: returns 1 AND FK created OR (0 AND FK already exists)
-- POST 02: throws exception if failed to create a non existent FK
-- ================================================================
CREATE PROCEDURE [dbo].[sp_create_FK]
    @fk_nm        VARCHAR(60)
   ,@f_table_nm   VARCHAR(60)
   ,@p_table_nm   VARCHAR(60)
   ,@f_col_nm     VARCHAR(60)
   ,@p_col_nm     VARCHAR(60) = NULL
   ,@cnt          INT         = NULL    OUT
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE 
    @fn           VARCHAR(35) = 'sp_create_FK'
   ,@sql          NVARCHAR(MAX)
   ,@NL           NVARCHAR(2) = NCHAR(13) + NCHAR(10)
   ,@msg          VARCHAR(500)
   ,@ret          INT  = 0
   ;

      EXEC sp_log 1, @fn ,' starting
fk_nm     :[', @fk_nm     ,']
f_table_nm:[', @f_table_nm,']
p_table_nm:[', @p_table_nm,']
p_table_nm:[', @p_table_nm,']
f_col_nm  :[', @f_col_nm  ,']
p_col_nm  :[', @p_col_nm  ,']
cnt       :[', @cnt       ,']
';

   IF @p_col_nm IS NULL  SET @p_col_nm = @f_col_nm;

   IF dbo.fnFkExists(@fk_nm) = 0
   BEGIN
      -- dbo.FkExists returns 1 if the foriegn exists, 0 otherwise
      SET @sql = CONCAT('
ALTER TABLE ', @f_table_nm,' WITH CHECK ADD CONSTRAINT ',@fk_nm,' FOREIGN KEY(',@f_col_nm,') 
REFERENCES ',@p_table_nm,'(',@p_col_nm,');
ALTER TABLE ', @f_table_nm,' CHECK CONSTRAINT ',@fk_nm,';');

      PRINT @sql;
      EXEC (@sql);

      SET @ret = dbo.fnFkExists(@fk_nm);

      IF @cnt IS NOT NULL SET @cnt = @cnt +1;

      -- POST 02: throws exception if failed to create a non existent FK
      EXEC sp_assert_equal 1, @ret, 'Failed to create FK: ', @fk_nm;
      EXEC sp_log 1, @fn ,'created FK ',@fk_nm;
   END
   ELSE
   BEGIN
      EXEC sp_log 1, @fn ,@fk_nm, ' already exists';
   END

   -- POST 01: returns 1 AND FK created OR (0 AND FK already exists)
   RETURN @ret;
END

GO
