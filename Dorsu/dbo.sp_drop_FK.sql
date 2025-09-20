SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Description: creates a releationship
-- Design:      
-- Tests:       
-- Author:      Terry Watts
-- Create date: 07-MAR-2025
--
-- PRECONDITIONS:
-- PRE 01 @fk_nm NOT NULL or EMPTY  Checked
-- =============================================
CREATE PROCEDURE [dbo].[sp_drop_FK]
    @fk_nm        VARCHAR(80)
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
     @fn          VARCHAR(35) = 'sp_drop_FK'
    ,@sql         NVARCHAR(MAX)
    ,@f_table_nm  VARCHAR(60)
    ,@f_schema_nm VARCHAR(60)
    ,@qtn         VARCHAR(120)
   ;

   BEGIN TRY
      EXEC sp_log 1, @fn, '000 starting
fk_nm:      [', @fk_nm     , ']';

   -----------------------------------------------------------------
   -- Validation
   -----------------------------------------------------------------
   -- PRE 01 @fk_nm NOT NULL or EMPTY  Checked
   EXEC sp_assert_not_null_or_empty @fk_nm, @fn=@fn;

   SELECT
       @f_table_nm  = f_table_nm
      ,@f_schema_nm = schema_nm
   FROM dbo.fnGetFk( @fk_nm);

   SET @qtn = CONCAT(@f_schema_nm,  '.', @f_table_nm);

   EXEC sp_log 1, @fn, '010 params:
fk_nm:      [', @fk_nm     , ']
f_table_nm: [', @f_table_nm, ']
f_schema_nm:[', @f_schema_nm,']
qtn:        [', @qtn        ,']
';

      IF @f_table_nm IS NULL
      BEGIN
         EXEC sp_log 1, @fn, '020: cannot find ', @fk_nm, ' skipping droppping it';
         RETURN;
      END

      EXEC sp_assert_not_null_or_empty @f_table_nm, '@f_table_nm';
      EXEC sp_log 1, @fn, '030: found ', @fk_nm, ', f_table_: ', @f_table_nm;

      ---------------------------------------------------------
      --- ASSERTION: @fk_nm exists
      ---------------------------------------------------------
      EXEC sp_assert_not_null_or_empty @f_table_nm, '@f_table_nm';

      SET @sql = CONCAT('IF dbo.fnFkExists(''', @fk_nm,''') = 1
BEGIN
   EXEC sp_log 1, ''',@fn,''','' 010: dropping constraint ', @qtn,'.',@fk_nm,''';
   ALTER TABLE ', @qtn,' DROP CONSTRAINT ',@fk_nm,';
END
ELSE
   EXEC sp_log 1, ''',@fn,''', ''020: constraint ',@fk_nm, ' not found'';
   ');

      EXEC sp_log 1, @fn, '040 @sql:
   ', @sql;

      EXEC sp_executesql @sql;

      IF dbo.fnFkExists(@fk_nm) = 1
         EXEC sp_raise_exception 50600, 'ERROR: ', @fk_nm, 'still exists ', @fn=@fn;
      ELSE
         EXEC sp_log 1, @fn, '499: successfully dropped: ', @fk_nm;
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   --EXEC sp_log 1, @fn, '999: leaving';
END
/*
EXEC test.sp__crt_tst_rtns 'sp_drop_FK';
*/

GO
