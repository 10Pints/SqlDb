SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO



-- =============================================
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
-- POST 01: FK created
-- =============================================
CREATE PROCEDURE [dbo].[sp_create_FK_old]
    @fk_nm        VARCHAR(60)
   ,@f_table_nm   VARCHAR(60)
   ,@p_table_nm   VARCHAR(60)
   ,@f_col_nm     VARCHAR(60)
   ,@p_col_nm     VARCHAR(60) = NULL
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE 
    @fn           VARCHAR(35) = 'sp_create_FK_old'
   ,@sql          NVARCHAR(MAX)
   ,@NL           NVARCHAR(2) = NCHAR(13) + NCHAR(10)
   ,@msg          VARCHAR(500)
   ;

      EXEC sp_log 1, @fn ,' starting
fk_nm     :[', @fk_nm     ,']
f_table_nm:[', @f_table_nm,']
p_table_nm:[', @p_table_nm,']
p_table_nm:[', @p_table_nm,']
f_col_nm  :[', @f_col_nm    ,']
p_col_nm  :[', @p_col_nm    ,']
';

 
   -- dbo.FkExists returns 1 if the foriegn exists, 0 otherwise
   SET @sql = CONCAT('IF dbo.fnFkExists(''', @fk_nm,''') = 0
   BEGIN
      ALTER TABLE ', @f_table_nm,' WITH CHECK ADD CONSTRAINT ',@fk_nm,' FOREIGN KEY(',@f_col_nm,') 
      REFERENCES ',@p_table_nm,'(',@p_col_nm,');
      ALTER TABLE ', @f_table_nm,' CHECK CONSTRAINT ',@fk_nm,';
   END
   ELSE
      PRINT ''constraint ',@fk_nm, ' already exists''');

   PRINT @sql;
   EXEC (@sql);

   IF dbo.fnFkExists(@fk_nm) = 1
   BEGIN
      EXEC sp_log 1, @fn ,'created FK ',@fk_nm;
   END
   ELSE
   BEGIN
      EXEC sp_log 4, @fn ,'failed to create FK ',@fk_nm;
      --THROW 68100, @msg, 1;
      EXEC sp_raise_exception 68100, @fn ,' failed to create FK:[',@fk_nm,'] ', @fn=@fn;
   END
END

GO
