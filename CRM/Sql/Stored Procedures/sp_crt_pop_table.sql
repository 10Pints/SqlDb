-- ==================================================================================
-- Author:      Terry Watts
-- Create date: 12-JUN-2025
-- Description: Create and populate a table from a data file
--
-- Design:      EA: Model.Use Case Model.Create and populate a table from a data file
-- Define the import data file path
-- Table name = file name
-- Reads the header for the column names
-- Create a table with table name, columns = field names, type = text
-- Create a staging table
-- Create a format file using BCP and the table
-- Generate the import routine using the table and the format file
--
-- Parameters:
--    @file_path     VARCHAR(500) -- the import data file path
-- Tests:       test_068_sp_crt_pop_table
--
-- Preconditions:
-- PRE01: @file_path populated, and must have folder
-- Postconditions:
-- ==================================================================================
CREATE PROCEDURE [dbo].[sp_crt_pop_table]
    @file_path       VARCHAR(500) -- the import data file path
   ,@q_tbl_nm        VARCHAR(100)= NULL
   ,@sep             VARCHAR(6)  = NULL
   ,@format_file     VARCHAR(500)= NULL
   ,@codepage        INT         = NULL
   ,@use_fmt_file    BIT         = 0
   ,@use_err_log     BIT         = 0
   ,@display_tables  BIT         = 0
AS
BEGIN
   SET NOCOUNT ON;

   DECLARE
    @fn           VARCHAR(35)   = N'sp_crt_pop_table'
   ,@fields       VARCHAR(8000)
   ,@table_nm     VARCHAR(60) = NULL
   ,@schema_nm    VARCHAR(60) = null
   ,@file         VARCHAR(500)
   ,@folder       VARCHAR(500)= NULL
   ,@NL           CHAR = CHAR(13)
   ,@tab          CHAR = CHAR(9)
   ,@ndx          INT
   ,@len          INT
   ,@exists       BIT
   ,@stg_table_nm VARCHAR(50)
   ,@row_cnt      INT
   ,@cmd          VARCHAR(8000)
   ,@sql          VARCHAR(8000)
   ,@crt_fmt_sql  VARCHAR(8000)
   ;

   BEGIN TRY
      DELETE FROM CrtPopTblInfo;
      -- pop the parameters
      INSERT INTO CrtPopTblInfo
      (
          file_path
         ,q_tbl_nm
         ,sep
         ,format_file
         ,[codepage]
         ,display_tables
         ,stage
      )
      VALUES
      (
          @file_path
         ,@q_tbl_nm
         ,@sep
         ,@format_file
         ,@codepage
         ,@display_tables
         ,1
      );

      IF @codepage IS NULL
         SET @codepage = 65001;

      IF @use_fmt_file = 0
         SET @format_file = NULL;

      EXEC sp_log 1, @fn, '000: starting:
@file_path:       [',@file_path     ,']
@q_tbl_nm:        [',@q_tbl_nm      ,']
@sep:             [',@sep           ,']
@format_file:     [',@format_file   ,']
@codepage:        [',@codepage      ,']
@use_fmt_file:    [',@use_fmt_file  ,']
@use_err_log:     [',@use_err_log   ,']
@display_tables:  [',@display_tables,']
';

      ---------------------------------------------------------------
      -- Validate
      ---------------------------------------------------------------

      IF @sep IS NULL OR @sep IN('',0x09,'0x09', '\t') SET @sep = @tab; -- default
      SET @len = dbo.fnLen(@file_path);
      SET @ndx = dbo.fnFindLastIndexOf('\', @file_path);
      -- PRE01: @file_path populated, and must have folder
      EXEC sp_assert_gtr_than @ndx, 0, @fn, ' PRE01: @file_path populated, and must have folder';

      IF @q_tbl_nm IS NOT NULL
      BEGIN
         EXEC sp_assert_not_equal '', @q_tbl_nm;
         SELECT
             @schema_nm = schema_nm
            ,@table_nm  = table_nm
         FROM dbo.fnSplitQualifiedTableName(@q_tbl_nm);
      END

      ---------------------------------------------------------------
      -- Setup
      ---------------------------------------------------------------

      -- Table name = file name less the extension
      SET @file   = SUBSTRING(@file_path, @ndx+2, @len-@ndx);
      SET @folder = iif(@ndx = 0, NULL, SUBSTRING(@file_path, 1, @ndx));

      UPDATE CrtPopTblInfo SET
          [len]   = @len
         ,ndx     = @ndx
         ,[file]  = @file
         ,folder  = @folder
         ,stage = 2
         ;

      IF @display_tables = 1 SELECT * FROM CrtPopTblInfo;

      -- Set table nm from the file name if not supplied
      IF @table_nm IS NULL
      BEGIN
         SELECT
             @schema_nm = 'dbo'
            ,@table_nm  = a FROM dbo.fnSplitPair2(@file, '.');

         EXEC sp_log 1, @fn, '020: Set table nm from the file name'
      END

      UPDATE CrtPopTblInfo SET
          schema_nm  = @schema_nm
         ,table_nm   = @table_nm
         ;

      EXEC sp_log 1, @fn, '010:
@len:      [', @len     , ']
@ndx:      [', @ndx     , ']
@file:     [', @file    , ']
@schema_nm:[', @schema_nm,']
@table_nm: [', @table_nm, ']
@folder:   [', @folder  , ']
';

      -- Import the header into a single column generic text table
      -- Reads the header for the column names
      -- Read the header for the column names

      -- Create the staging table,  columns = field names, type = text
      -- Create a staging table
      SET @stg_table_nm = CONCAT(@table_nm, 'Staging');
      EXEC sp_drop_table @stg_table_nm;

      -- Create a table with table name, columns = field names, type = text
      EXEC sp_log 1, @fn, '030: creating the staging table, cmd: ', @NL, @cmd;
      SELECT @fields = staging FROM GenericStaging;
      EXEC sp_log 1, @fn, '040: @fields: ', @fields;
      EXEC sp_log 1, @fn, '045: @stg_table_nm: ',@stg_table_nm;

      SET @cmd = dbo.fnCrtTblSql(@stg_table_nm, @fields); -- delimits the qualified @stg_table_nm if necessary
      EXEC sp_log 1, @fn, '050: executing Create table sql:',@NL, @cmd;

      UPDATE CrtPopTblInfo SET
          crt_stg_tbl_sql  = @cmd
         ,fields           = @fields
         ;

      EXEC (@cmd);
      -- Bracket table name as necessary
      -- Bracket field names as necessary
      -- Create a format file using BCP and the table
      --SET @cmd = dbo.fnCrtTblSql(@table_nm, @fields);
      --EXEC sp_log 1, @fn, '060: creating the main table, sql: ', @NL, @cmd;
      --EXEC (@cmd);

   -- Create and populate the table from data file : Create and populate a table from a data file_ActivityGraph
   -- Infer the field types from the staged data
   -- Merge the staging table to the main table

      -- Create a format file using BCP and the table
      IF @format_file IS NULL AND @format_file = 1
      BEGIN
         EXEC sp_log 1, @fn, '051: Creating a format file using BCP and the table ';
         -- LIKE: bcp CRM.dbo.PropertySalesStaging format nul -c -x -f "D:\Dev\CRM\SQL\Tests\068_sp_crt_pop_table\test_068_fmt.xml" -T -S DevI9
         SET @format_file = CONCAT(@folder, '\',@table_nm,'_fmt.xml');-- fmt xml
         --SET @cmd = CONCAT('bcp ',DB_NAME(),'.dbo.',@table_nm,' format nul -c -x -f ',@format_file, ' -t, -T');
         SET @cmd =
            CONCAT
            (
               'bcp '
              ,DB_NAME()
              ,'.dbo.',@table_nm
              ,' format nul -c -x -f "',@format_file, '"'
              ,iif(@sep=@tab, '', ' -t, '),' -T -S', @@SERVERNAME
            );

         EXEC sp_log 1, @fn, '060: creating format file: ', @NL, @cmd;

         UPDATE CrtPopTblInfo SET
             crt_fmt_sql  = @cmd
            ;

         EXEC xp_cmdshell @cmd;
         EXEC sp_log 1, @fn, '062: executed the BCP command: checking file exists';
         SET @exists = dbo.fnFileExists(@format_file)
         EXEC sp_log 1, @fn, '063: file exists: ',@exists;
      END

      -- Import the staging table
      -- Import staging table using the table and the format file
      EXEC sp_log 1, @fn, '070: importing ', @file_path, ' to staging: ', @stg_table_nm;

      EXEC sp_import_txt_file
          @table            = @stg_table_nm
         ,@file             = @file_path
         ,@folder           = NULL
         ,@field_terminator = @sep
         ,@codepage         = @codepage
         ,@first_row        = 2
         ,@format_file      = @format_file
         ,@use_err_log      = @use_err_log
         ,@display_table    = @display_tables
      ;

      -- Infer the field types from the staged data
      EXEC sp_log 1, @fn, '080: Infer the field types from the staged data';
      EXEC sp_log 1, @fn, '085: calling sp_infer_field_types @stg_table_nm: [',@stg_table_nm,']';

      -- Infer field types: pops the FieldInfo table
      EXEC sp_infer_field_types @stg_table_nm;
      SELECT * FROM FieldInfo;

      EXEC sp_log 1, @fn, '090: Drop the main  if it exists';

      -- Drop table if it exists
      EXEC sp_drop_table @table_nm;


      -- Create the main table with table name, columns = field names, type = inferred type
      EXEC sp_log 1, @fn, '100: Create the main table with table name, columns = field names, type = inferred type';
      SELECT @sql =
      CONCAT
      (
      'CREATE TABLE ', @table_nm, '
(
'
,STRING_AGG(CONCAT('   ', lower(nm), ' ', ty), ',
'
),'
);'
      )
      FROM FieldInfo
      ;
      EXEC sp_log 1, @fn, '110: Creating the main table, sql:
', @sql;

      UPDATE CrtPopTblInfo SET
          crt_tbl_sql   = @sql;

      EXEC(@sql);

      -- Migrating the staging data to the main table
      SET @sql = CONCAT('INSERT INTO ', @table_nm,' SELECT * FROM ',@stg_table_nm,';')
      EXEC sp_log 1, @fn, '120: Migrating the staging data to the main table, @sql:
', @sql;

      UPDATE CrtPopTblInfo SET copy_to_mn_tbl_sql = @sql;

      EXEC(@sql);

      SELECT @table_nm as [main table];
      -- DEBUG
      IF @display_tables = 1 SELECT * FROM CrtPopTblInfo;
      SET @sql = CONCAT('SELECT * FROM ',@table_nm,';')
      EXEC sp_log 1, @fn, '130: displaying the main table';
      EXEC(@sql);
   END TRY
   BEGIN CATCH
      EXEC sp_log 4, @fn, '500: Caught exception';
      EXEC sp_log_exception @fn;
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: completed processing';
END
/*
EXEC test.test_068_sp_crt_pop_table;
*/