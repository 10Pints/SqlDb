SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

-- =============================================
-- Author:      Terry Watts
-- Create date: 13-APR-2025
-- Description: Removes double quotes
-- EXEC tSQLt.Run 'test.test_<nnn>_<proc_nm>';
-- Design:      
-- Tests:       
-- =============================================
CREATE PROCEDURE [dbo].[sp_RemoveDoubleQuotes]
    @table_no_brkts    VARCHAR(60)
   ,@max_len_fld       INT
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
    @fn                 VARCHAR(35)       = N'sp_import_txt_file'
   ,@table              VARCHAR(60)
   ,@nl                 CHAR(2)           = CHAR(13)+CHAR(10)
   ,@sql                VARCHAR(4000)

   EXEC sp_log 1, @fn, '000: starting:
table_no_brkts  :[',@table_no_brkts,']
max_len_fld     :[',@max_len_fld   ,']
';

      ----------------------------------------------------------------------------------
      -- R02: Remove double quotes
      -- R03: Trim leading/trailing whitespace
      -- R04: Remove line feeds
      ----------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '135: @table_nm_no_brkts: ', @table_no_brkts;
      EXEC sp_log 1, @fn, '135: @table : ', @table ;

      WITH cte AS
      (
         SELECT dbo.fnPadRight(CONCAT('[', column_name, ']'), @max_len_fld+2) AS column_name,ROW_NUMBER() OVER (ORDER BY ORDINAL_POSITION) AS row_num, ordinal_position, DATA_TYPE, is_txt
         FROM list_table_columns_vw 
         WHERE table_name = @table_no_brkts AND is_txt = 1
      )
      ,cte2 AS
      (
         SELECT CONCAT('UPDATE ',@table,' SET ') AS sql
         UNION ALL
         SELECT CONCAT( iif(row_num=1, ' ',','), column_name, ' = TRIM(REPLACE(REPLACE(',column_name, ', ''"'',''''), NCHAR(10), ''''))') 
         FROM cte
         UNION ALL
         SELECT CONCAT('FROM ',@table,';')
      )
      SELECT @sql = string_agg(sql, @NL) FROM cte2;

      EXEC sp_log 1, @fn, '150: trim replacing double quotes, @sql:', @NL, @sql;
      EXEC (@sql);

     EXEC sp_log 1, @fn, '000: leaving'

END
/*
EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_<proc_nm>';
*/

GO
