SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- ==========================================================================================================
-- Author:      Terry Watts
-- Create date: 28-FEB-2024
-- Description: 
--
-- PRECONDITIONS:
-- PRE 01: @spreadsheet must be specified OR EXCEPTION 58000, 'spreadsheet must be specified'
-- PRE 02: @spreadsheet exists,           OR EXCEPTION 58001, 'spreadsheet does not exist'
-- PRE 03: @range not null or empty       OR EXCEPTION 58002, 'range must be specified'
-- 
-- POSTCONDITIONS:
-- POST01:
--
-- CALLED BY:
-- sp_import_XL_new, sp_import_XL_existing
--
-- TESTS:
--
-- CHANGES:
-- 05-MAR-2024: put brackets around the field names to handle spaces reserved words etc.
-- 05-MAR-2024: added parameter validation
-- ==========================================================================================================
CREATE PROCEDURE [dbo].[sp_get_flds_frm_hdr_xl]
    @import_file  VARCHAR(500)                 -- include path, and optional range
   ,@range        VARCHAR(100) -- = N'Sheet1$'   -- for XL: like 'Table$' OR 'Table$A:B'
   ,@fields       VARCHAR(4000) OUT            -- comma separated list
AS
BEGIN
   DECLARE 
    @fn           VARCHAR(35)   = N'GET_FLDS_FRM_HDR_XL'
   ,@cmd          NVARCHAR(4000)
   ,@n            INT

   EXEC sp_log 1, @fn, '000: starting, 
@import_file:  [', @import_file,']
@range:        [', @range,']
@fields:       [', @fields,']
';

   BEGIN TRY
      -------------------------------------------------------
      -- Param validation, fixup
      -------------------------------------------------------
      SET @n = charindex('!', @import_file, 0);
      IF( @n > 0)
      BEGIN
         SET @range = SUBSTRING(@import_file, @n+1, 100);
         SET @import_file = SUBSTRING(@import_file,1, @n-1);
      END

      -- soert out []$ etc.
      SET @range = dbo.fnFixupXlRange(@range);

      --------------------------------------------------------------------------------------------------------
      -- PRE 01: @spreadsheet must be specified OR EXCEPTION 58000, 'spreadsheet must be specified'
      --------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '010: checking PRE 01,. @range: [',@range,']';
      EXEC sp_assert_not_null_or_empty @import_file, 'spreadsheetfile  must be specified', @ex_num=58000--, @fn=@fn;

      --------------------------------------------------------------------------------------------------------
      -- PRE 02: @spreadsheet exists,           OR EXCEPTION 58001, 'spreadsheet does not exist'
      --------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '020: checking PRE 02';

      IF dbo.fnFileExists(@import_file) = 0 
         EXEC sp_raise_exception 58001, @import_file, ' does not exist'--, @fn=@fn

      --------------------------------------------------------------------------------------------------------
      -- PRE 03: @range not null or empty       OR EXCEPTION 58002, 'range must be specified'
      --------------------------------------------------------------------------------------------------------
      EXEC sp_log 1, @fn, '025: checking PRE 03';
      EXEC sp_assert_not_null_or_empty @range, 'range must be specified', @ex_num=58002--, @fn=@fn;

      -------------------------------------------------------
      -- ASSERTION: Passed parameter validation
      -------------------------------------------------------
      EXEC sp_log 1, @fn, '030: Passed parameter validation';

      -------------------------------------------------------
      -- Process
      -------------------------------------------------------
      EXEC sp_log 1, @fn, '040: processing';
      DROP TABLE IF EXISTS temp;

      -- IMEX=1 treats everything as text
      SET @cmd = 
         CONCAT
         (
      'SELECT * INTO temp 
      FROM OPENROWSET
      (
          ''Microsoft.ACE.OLEDB.12.0''
         ,''Excel 12.0;IMEX=1;HDR=NO;Database='
         ,@import_file,';''
         ,''SELECT TOP 2 * FROM ',@range,'''
      )'
         );

      EXEC sp_log 1, @fn, '050: open rowset sql:
   ', @cmd;

      EXEC(@cmd);
      SELECT @fields = string_agg(CONCAT('concat (''['',','', column_name, ','']''',')'), ','','',') FROM list_table_columns_vw WHERE TABLE_NAME = 'temp';
      SELECT @cmd = CONCAT('SET @fields = (SELECT TOP 1 CONCAT(',@fields, ') FROM [temp])');
      EXEC sp_log 1, @fn, '060: get fields sql:
   ', @cmd;

      EXEC sp_executesql @cmd, N'@fields VARCHAR(4000) OUT', @fields OUT;
   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn;
      EXEC sp_log 4, @fn, '500: parameters, 
import_file:  [', @import_file,']
range:        [', @range,']'
;
      THROW
   END CATCH
   EXEC sp_log 1, @fn, '99: leaving, OK';
END
/*
DECLARE @fields VARCHAR(MAX);
EXEC sp_get_fields_from_xl_hdr 'D:\Dev\Repos\Farming\Data\Distributors.xlsx!Distributors$A:H', @fields OUT;
PRINT @fields;
*/



GO
